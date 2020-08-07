# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rsan
class rsan (
  String $pdb = 'master.platform9.puppet.net',
  Array $infranode = ',[master.platform9.puppet.net, 8140] ,[compiler.platform9.puppet.net, 8140]',
  String $postgres = $pdb ,
){


  class { 'nfs':
      server_enabled => true,
    }


  include postgresql::client
  include puppet_enterprise::profile::controller

        NFS::Client::Mount <<| |>>


  class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  overwrite_dashboards   => false,
  configure_telegraf     => true,
  enable_telegraf        => true,
  master_list            => $infranode,
  puppetdb_list          => [$pdb],
  postgres_host_list     => [$postgres],

}
  }
