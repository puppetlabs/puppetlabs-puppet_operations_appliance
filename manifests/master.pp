# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rsan::master
class rsan::master(
  String $rsanip = '192.168.0.20',
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
  include puppet_metrics_dashboard::profile::master::install
  include puppet_metrics_collector
  include puppet_metrics_dashboard::profile::master::postgres_access
  }
