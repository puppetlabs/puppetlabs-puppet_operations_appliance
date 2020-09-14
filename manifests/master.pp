# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rsan::master
class rsan::master(
  String $rsanip = '192.168.0.20',
  Optional[String[1]] $rsan_host = undef
)  {

  class { '::nfs':
  server_enabled => true
  }
  nfs::server::export{ '/var/log/':
  ensure  => 'mounted',
  clients => "${rsanip}(ro,insecure,async,no_root_squash) localhost(ro)",
  mount   => "/var/pesupport/${facts['fqdn']}/log",
  }
  nfs::server::export{ '/opt/puppetlabs/':
  ensure  => 'mounted',
  clients => "${rsanip}(ro,insecure,async,no_root_squash) localhost(ro)",
  mount   => "/var/pesupport/${facts['fqdn']}/opt",
  }
  nfs::server::export{ '/etc/puppetlabs/':
  ensure  => 'mounted',
  clients => "${rsanip}(ro,insecure,async,no_root_squash) localhost(ro)",
  mount   => "/var/pesupport/${facts['fqdn']}/etc",
  }

  if $rsan_host {
    $_rsan_host = $rsan_host
  } else {
    $_query = puppetdb_query('resources[certname] {
      type = "Class" and
      title = "Rsan" and
      nodes {
        deactivated is null and
        expired is null
      }
      order by certname asc
      limit 1
    }')
    unless $_query.empty {
      $_rsan_host = $_query[0]['certname']
    }
  }

  # If $rsan_host is not defined and the query fails to find a rsan  host, issue a warning.

  if $_rsan_host == undef {

    notify { 'You must specify rsan_host (or apply the rsan class to an agent) to enable access.': }

  } else {

    pe_postgresql::server::role { 'rsan': }

    pe_postgresql::server::database_grant { 'rsan':
      privilege => 'SELECT',
      db        => 'pe-puppetdb',
      role      => 'rsan',
    }

    # If the fact doesn't exist then PostgreSQL is probably version 9.4.

    if $facts['pe_postgresql_info']['installed_server_version'] {
      $postgres_version = $facts['pe_postgresql_info']['installed_server_version']
    } else {
      $postgres_version = '9.4'
    }

    puppet_enterprise::pg::cert_whitelist_entry { 'allow-rsan-access':
      user                          => 'rsan',
      database                      => 'pe-puppetdb',
      allowed_client_certname       => $_rsan_host,
      pg_ident_conf_path            => "/opt/puppetlabs/server/data/postgresql/${postgres_version}/data/pg_ident.conf",
      ip_mask_allow_all_users_ssl   => '0.0.0.0/0',
      ipv6_mask_allow_all_users_ssl => '::/0',
    }

  include puppet_metrics_dashboard::profile::master::install
  include puppet_metrics_collector
  include puppet_metrics_dashboard::profile::master::postgres_access

  }
}
