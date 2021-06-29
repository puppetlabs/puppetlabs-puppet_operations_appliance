# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include openvpn_client
class rsan::openvpn_client (
  String $openvpn_service = 'stopped',
  String $openvpn_server = 'enter VPN server Address',
  String $openvpn_port = '943',
  String $openvpn_newconf = 'yes',
  String $license_file = '/etc/puppetlabs/license.key',
)
{

  # EPEL-Release is required for centos and needs to be added as a dependency

  # Installs openvpn client software

  package {'openvpn':
    ensure   => 'present',
  }

  # Copies openvpn conneciton script

  file { '/etc/openvpn/openvpnconnecion.sh':
    ensure    => file,
    source    => 'puppet:///modules/rsan/openvpnconnecion.sh',
    subscribe => Package['openvpn'],
  }

  # Obtains license file from PE server so we can extract UUID for vpn password connection

  #$file_path = $license_file

  $license_exists = find_file($license_file)

  if $license_exists  {

    $content = file($license_file)

    $license_uuid = rsan::license_uuid($content)

    notify { 'openvpnconneciton':
      name    => openvpnconneciton,
      message => "Credential: ${license_uuid}",
    }

    # Requires customer username and password to connect to the relevant OpenVPN Access server profile. Then stores connection details to
    # the openvpn client folder 

    $openvpn_command = "curl -u customer:${license_uuid} https://${openvpn_server}:${openvpn_port}/rest/GetAutologin -k > /etc/openvpn/puppet.conf"

    # Allows to create a new openvpn client connection file on request using variable $openvpn_newconf
    # otherwise uses existing openvpn client connection file (/etc/openvpn/puppet.conf)

    if $openvpn_newconf == 'yes' {
      exec {'openvpn client conf':
        command  => $openvpn_command,
        provider => shell,
        require  => Package['openvpn'],
      }
      $openvpn_confaction = Exec['openvpn client conf']
    } else {
      $openvpn_confaction = Package['openvpn']
    }

    # Ensures that there is an openvpn client connection file before initiating a connection

    file {'/etc/openvpn/puppet.conf':
      ensure  => file,
      path    => '/etc/openvpn/puppet.conf',
      mode    => '0600',
      require => $openvpn_confaction,
    }

    # Creates a service for the openvpn connection and set the status based on $openvpn_service variable

    service { 'openvpn@puppet':
      ensure    => $openvpn_service,
      enable    => true,
      subscribe => File['/etc/openvpn/puppet.conf'],
    }


  }
  else
  {
    notify { 'openvpnnolicense':
      name    => openvpnnolicense,
      message => 'Unable to get UUID',
    }
  }

}
