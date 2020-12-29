# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   rsan::openvpnclient { 'namevar': }
define rsan::openvpnclient (
  $auth              = undef,
  $auth_user_pass    = undef,
  $ca                = undef,
  $cert              = undef,
  $cipher            = undef,
  $client            = true,
  $comp_lzo          = undef,
  $custom_options    = [],
  $dev               = undef,
  $group             = undef,
  $key               = undef,
  $nobind            = true,
  $ns_cert_type      = undef,
  $persist_key       = true,
  $persist_remote_ip = true,
  $persist_tun       = true,
  $port              = undef,
  $proto             = undef,
  $remote_cert_tls   = undef,
  $resolv_retry      = undef,
  $server            = $name,
  $tls_client        = true,
  $user              = undef,
  $verb              = undef,
) {


  validate_array($custom_options)
  validate_bool($client, $nobind, $persist_key, $persist_remote_ip,
  $persist_tun, $tls_client)
  unless $auth == undef { validate_string($auth) }
  unless $auth_user_pass == undef { validate_absolute_path($auth_user_pass) }
  unless $ca == undef { validate_absolute_path($ca) }
  unless $cert == undef { validate_absolute_path($cert) }
  unless $cipher == undef { validate_string($cipher) }
  unless $comp_lzo == undef { validate_string($comp_lzo) }
  unless $dev == undef { validate_string($dev) }
  unless $group == undef { validate_string($group) }
  unless $key == undef { validate_absolute_path($key) }
  unless $ns_cert_type == undef { validate_string($ns_cert_type) }
  unless $port == undef { validate_integer($port) }
  unless $proto == undef { validate_string($proto) }
  unless $remote_cert_tls == undef { validate_string($remote_cert_tls) }
  unless $resolv_retry == undef { validate_string($resolv_retry) }
  unless $server == undef { validate_string($server) }
  unless $user == undef { validate_string($user) }
  unless $verb == undef { validate_integer($verb) }

  file { "${rsan::exporter::openvpn_dir}/${server}.conf":
    mode    => '0640',
    content => template('rsan/client.conf.erb')
  }

  File["${rsan::exporter::openvpn_dir}/${server}.conf"]
  ~> Service[$rsan::importer::service_name]
}
