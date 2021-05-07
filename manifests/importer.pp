# Class to consume the resources provided by the exporter class.
# when applied to a node, all tooling agttributed to RSAN will be set up
# @example
#   include rsan::importer
class rsan::importer {

  ##################### 1.Import logging from the exporter groups #####################
  # depending on the method, could be import exported respore with rsan tag
  #####################################################################################

  class { '::nfs':
    client_enabled => true,
  }
  Nfs::Client::Mount <<| nfstag == 'rsan' |>>


  #################### 2. Deploy Client tools, and deploy PSL client #################
  # include postgresql::client , include puppet_enterprise::profile::controller need to make postgresql module a dependancies
  ####################################################################################

  include postgresql::client
  include puppet_enterprise::profile::controller

  pe_ini_setting { 'Key Permisions for Psql client':
    ensure  => present,
    path    => "${::puppet_enterprise::params::confdir}/puppet.conf",
    section => 'main',
    setting => 'hostprivkey',
    value   => '$privatekeydir/$certname.pem{mode = 0600}',
  }



  ################### 3. Telemetry dashboard ########################################
  # If using puppet_metrics_dashboard:

  #
  # this is where lists of master_list , puppetdb_list, postgres_host_list hosts are found using a puppetdb query
  #make sure each list is same format

  #conditions of whether postgres is present or not

  #in the below class 

    $puppet_servers = rsan::get_puppet_servers()
    $puppetdb_hosts = rsan::get_puppetdb_hosts()
    $postgres_hosts = rsan::get_postgres_hosts()

    class { 'puppet_metrics_dashboard':
      add_dashboard_examples => true,
      overwrite_dashboards   => false,
      configure_telegraf     => true,
      enable_telegraf        => true,
      master_list            => $puppet_servers,
      puppetdb_list          => $puppetdb_hosts,
      postgres_host_list     => $postgres_hosts,
    }

      # master_list , puppetdb_list, postgres_host_list need to be queried  from the system programatically



  #######################################################################################





}
