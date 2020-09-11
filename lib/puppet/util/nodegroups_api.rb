require 'puppet/network/http_pool'
require 'json'

class Puppet::Util::Nodegroups_api
  def initialize
    pe_agent_config = JSON.parse(Facter::Util::Resolution.exec('sudo -u root /opt/puppetlabs/bin/puppet config print --render-as json'))

    settings_file = "#{pe_agent_config['confdir']}/classifier.yaml"

    begin
      nc_settings = YAML.load_file(settings_file)
      nc_settings = nc_settings.first if nc_settings.class == Array
    rescue
      fail "Could not find file #{settings_file}"
    else
      cl_server       = nc_settings['server'] || pe_agent_config['server']
      cl_port         = nc_settings['port']   || 4433
      @classifier_url = "https://#{cl_server}:#{cl_port}/classifier-api"
      @token          = nc_settings['token']
      unless cl_server == pe_agent_config['certname']
        remote_client = "#{Facter.value('fqdn')} (#{Facter.value('ipaddress')})"
        Puppet.debug("Managing node_group remotely from #{remote_client}")
      end
      Puppet.debug("classifier_url: #{@classifier_url}")

      unless @token and ! @token.empty?
        @ca_certificate_path = nc_settings['localcacert'] || pe_agent_config['localcacert']
        @certificate_path    = nc_settings['hostcert']    || pe_agent_config['hostcert']
        @private_key_path    = nc_settings['hostprivkey'] || pe_agent_config['hostprivkey']
      end
    end
  end

  def get_groups
    res = do_https('v1/groups', 'GET')
    if res.code.to_i != 200
      error_msg(res)
      fail('Unable to get node_group list')
    else
      JSON.parse(res.body)
    end
  end

  private

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
end
