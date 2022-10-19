# Class to consume the resources provided by the exporter class.
# when applied to a node, all tooling agttributed to RSAN will be set up
# @example
#   include rsan::importer
class rsan::importer {
  ##################### 1.Import logging from the exporter groups #####################
  # depending on the method, could be import exported respore with rsan tag
  #####################################################################################

  class { 'nfs':
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
    path    => "${facts['puppet_enterprise::params::confdir']}/puppet.conf",
    section => 'main',
    setting => 'hostprivkey',
    value   => '$privatekeydir/$certname.pem{mode = 0600}',
  }

  ################### 3. Operational dashboards deployment ########################################

  include puppet_operational_dashboards
  #######################################################################################}
