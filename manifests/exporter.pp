# Sets up target nodes with nessary services and access for the puppet_operations_appliance
# When Applied to the Infrastructure Agent Node group, 
# Will dynamically configure all matching nodes to allow
#access to key elements of Puppet Enterprise to the puppet_operations_appliance 
# @param [Array] importer_ips
#   An array of importer node ip addresses
#   Defaults to the output of a PuppetDB query
# @param [Optional[String]] appliance_host
#   The certname of the puppet_operations_appliance 
# @param [Optional[String]] pg_user
#   The postgres user PE uses 
# @param [Optional[String]] pg_group
#   The postgres group PE uses the default is pg_user
# @param [Optional[String]] pg_psql_path
#   The path to the postgres binary in pe
# @param [Boolean] nfsmount_log
#   Trigger to turn NFS Mounts for logging On Or Off
# @param [Boolean] nfsmount_etc
#   Trigger to turn NFS Mounts for /etc/puppetlabs On Or Off
# @param [Boolean] nfsmount_opt
#   Trigger to turn NFS Mounts for /opt/puppetlabs On Or Off
# @param [Optional[Enum]] logdir
#   Allows the scope of logging to be narrowed
# @example
#   include puppet_operations_appliance::exporter
class puppet_operations_appliance::exporter (
  Array $importer_ips = puppet_operations_appliance::get_importer_ips(),
  Optional[String] $appliance_host = undef,
  String $pg_user = 'pe-postgres',
  String $pg_group = $pg_user,
  String $pg_psql_path = '/opt/puppetlabs/server/bin/psql',
  Enum['/var/log/', '/var/log/puppetlabs/'] $logdir = '/var/log/',
  Boolean $nfsmount_log = true,
  Boolean $nfsmount_etc = true,
  Boolean $nfsmount_opt= true,
) {
  # Setup the NFS Mounts for the appliance

  class { 'nfs':
    server_enabled => true,
  }

  $ensure_log = $nfsmount_log ? {
    true  => 'mounted',
    false => 'absent',
  }

  $ensure_etc = $nfsmount_etc ? {
    true  => 'mounted',
    false => 'absent',
  }

  $ensure_opt = $nfsmount_opt ? {
    true  => 'mounted',
    false => 'absent',
  }

  $_clients = $importer_ips.reduce('') |$memo, $ip| {
    "${memo} ${ip}(ro,insecure,async,no_root_squash)"
  }
  $clients = "${_clients} localhost(ro)"

  nfs::server::export { $logdir:
    ensure      => $ensure_log,
    clients     => $clients,
    mount       => "/var/pesupport/${facts['networking']['fqdn']}/log",
    options_nfs => 'tcp,nolock,rsize=32768,wsize=32768,soft,noatime,actimeo=3,retrans=1',
    nfstag      => 'puppet_operations_appliance',
  }
  nfs::server::export { '/opt/puppetlabs/':
    ensure      => $ensure_opt,
    clients     => $clients,
    mount       => "/var/pesupport/${facts['networking']['fqdn']}/opt",
    options_nfs => 'tcp,nolock,rsize=32768,wsize=32768,soft,noatime,actimeo=3,retrans=1',
    nfstag      => 'puppet_operations_appliance',
  }
  nfs::server::export { '/etc/puppetlabs/':
    ensure      => $ensure_etc,
    clients     => $clients,
    mount       => "/var/pesupport/${facts['networking']['fqdn']}/etc",
    options_nfs => 'tcp,nolock,rsize=32768,wsize=32768,soft,noatime,actimeo=3,retrans=1',
    nfstag      => 'puppet_operations_appliance',
  }

  # Install operational dashboards on PE infrastructure nodes

  include puppet_operational_dashboards::enterprise_infrastructure

  if $facts['pe_postgresql_info'] != undef and $facts['pe_postgresql_info']['installed_server_version'] != '' {
    if $appliance_host {
      $_appliance_host = $appliance_host
    } else {
    $_query = puppetdb_query('resources[certname] {
        type = "Class" and
        title = "Puppet_operations_appliance::Importer" and             
        nodes {
          deactivated is null and
          expired is null
        }
        order by certname asc
        limit 1
      }')
      unless $_query.empty {
        $_appliance_host = $_query[0]['certname']
      }
    }

    # If $appliance_host is not defined and the query fails to find an appliance host, issue a warning.

    if $_appliance_host == undef {
      notify { 'You must specify appliance_host (or apply the puppet_operations_appliance class to an agent) to enable access.': }
    } else {
      pe_postgresql::server::role { 'puppet_operations_appliance': }

      if $facts['pe_postgresql_info']['installed_server_version'] {
        $postgres_version = $facts['pe_postgresql_info']['installed_server_version']
      } else {
        $postgres_version = '9.4'
      }

      # Due to the advent of PE_XL different postgres instances contain different schemas
      # this conditional compensates by checking for pe_xl role facts

      if $trusted['extensions']['1.3.6.1.4.1.34380.1.1.9812'] == 'puppet/puppetdb-database' {
        $dbs = ['pe-puppetdb']
      } elsif $trusted['extensions']['1.3.6.1.4.1.34380.1.1.9812'] == 'puppet/server' {
        $dbs = ['pe-activity', 'pe-classifier', 'pe-inventory', 'pe-rbac', 'pe-orchestrator']
      } else {
        $dbs = ['pe-activity', 'pe-classifier', 'pe-inventory', 'pe-puppetdb', 'pe-rbac', 'pe-orchestrator']
      }

      $dbs.each |$db| {
        pe_postgresql::server::database_grant { "CONNECT to puppet_operations_appliance for ${db}":
          privilege => 'CONNECT',
          db        => $db,
          role      => 'puppet_operations_appliance',
          require   => Pe_postgresql::Server::Role['puppet_operations_appliance'],
        }

        $grant_cmd = "GRANT SELECT ON ALL TABLES IN SCHEMA \"public\" TO puppet_operations_appliance"
        pe_postgresql_psql { "${grant_cmd} on ${db}":
          command    => $grant_cmd,
          db         => $db,
          port       => $pe_postgresql::server::port,
          psql_user  => $pg_user,
          psql_group => $pg_group,
          psql_path  => $pg_psql_path,
          unless     => "SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE privilege_type = 'SELECT' AND grantee = 'puppet_operations_appliance'",
          require    => [
            Class['pe_postgresql::server'],
            Pe_postgresql::Server::Role['puppet_operations_appliance']
          ],
        }

        puppet_enterprise::pg::cert_allowlist_entry { "allow-puppet_operations_appliance-access for ${db}":
          user                          => 'puppet_operations_appliance',
          database                      => $db,
          allowed_client_certname       => $_appliance_host,
          pg_ident_conf_path            => "/opt/puppetlabs/server/data/postgresql/${postgres_version}/data/pg_ident.conf",
          ip_mask_allow_all_users_ssl   => '0.0.0.0/0',
          ipv6_mask_allow_all_users_ssl => '::/0',
        }
      }
    }
  }
}
