require 'json'

Puppet::Functions.create_function(:nodegroups) do
  dispatch :nodegroups do
    required_param 'String', :puppet_data
    optional_param 'String', :node_name
  end

  def nodegroups(puppet_data, node_name = '')
    puppet_settings = JSON.parse(puppet_data)
    settings_file = "#{puppet_settings['confdir']}/classifier.yaml"

    begin
      nc_settings = YAML.load_file(settings_file)
      nc_settings = nc_settings.first if nc_settings.class == Array
    rescue
      fail "Could not find file #{settings_file}"
    else
      cl_server       = nc_settings['server'] || puppet_settings['server']
      cl_port         = nc_settings['port']   || 4433
      @classifier_url = "https://#{cl_server}:#{cl_port}/classifier-api"
      @token          = nc_settings['token']
      unless cl_server == puppet_settings['certname']
        remote_client = "#{Facter.value('fqdn')} (#{Facter.value('ipaddress')})"
        Puppet.debug("Managing node_group remotely from #{remote_client}")
      end
      Puppet.debug("classifier_url: #{@classifier_url}")

      unless @token and ! @token.empty?
        @ca_certificate_path = nc_settings['localcacert'] || puppet_settings['localcacert']
        @certificate_path    = nc_settings['hostcert']    || puppet_settings['hostcert']
        @private_key_path    = nc_settings['hostprivkey'] || puppet_settings['hostprivkey']
      end
    end

    res = do_https('v1/groups', 'GET')
    if res.code.to_i != 200
      error_msg(res)
      fail('Unable to get node_group list')
    else
      groups = JSON.parse(res.body)
    end

    # When querying a specific group
    if node_name.length.zero?
      hashify_group_array(groups)
    else
      # Assuming there is only one group by the name
      hashify_group_array(
        groups.select { |g| g['name'] == node_name }
      )
    end
  end

  def do_https(endpoint, method = 'post', data = {})
    url  = "#{@classifier_url}/#{endpoint}"
    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)

    unless @token and ! @token.empty?
      Puppet.debug('Using SSL authentication')
      http.use_ssl     = true
      http.cert        = OpenSSL::X509::Certificate.new(File.read @certificate_path)
      http.key         = OpenSSL::PKey::RSA.new(File.read @private_key_path)
      http.ca_file     = @ca_certificate_path
      http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE
    else
      Puppet.debug('Using token authentication')
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    req              = Net::HTTP.const_get(method.capitalize).new(uri.request_uri)
    req.body         = data.to_json
    req.content_type = 'application/json'

    # If using token
    req['X-Authentication'] = @token if @token

    begin
      res = http.request(req)
    rescue Exception => e
      fail(e.message)
      debug(e.backtrace.inspect)
    else
      res
    end
  end

  def error_msg(res)
    json = JSON.parse(res.body)
    kind = json['kind']
    msg  = json['msg']
    Puppet.err %(node_manager failed with error type '#{kind}': #{msg})
    Puppet.debug("Response code: #{res.code}")
    Puppet.debug("Response message: #{res.body}")
  end

  def hashify_group_array(group_array)
    hashified = Hash.new

    group_array.each do |group|
      hashified[group['name']] = group
    end

    hashified
  end

end
