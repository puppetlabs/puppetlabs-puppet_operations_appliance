# Class to consume the resources provided by the exporter class.
# when applied to a node, all tooling agttributed to puppet_operations_appliance will be set up
# @example
#   include puppet_operations_appliance::importer
class puppet_operations_appliance::importer {
  # Import the logs by mounting the NFS mountpoints from the exporter nodes
  class { 'nfs':
    client_enabled => true,
  }
  Nfs::Client::Mount <<| nfstag == 'puppet_operations_appliance' |>>

  # Deploy Client tools, and deploy PSL client

  include postgresql::client
  include puppet_enterprise::profile::controller

  pe_ini_setting { 'Key Permisions for Psql client':
    ensure  => present,
    path    => "${facts['puppet_enterprise::params::confdir']}/puppet.conf",
    section => 'main',
    setting => 'hostprivkey',
    value   => '$privatekeydir/$certname.pem{mode = 0600}',
  }

  # Operational dashboards deployment 

  include puppet_operational_dashboards
}
