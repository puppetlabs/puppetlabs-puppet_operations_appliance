#
# When Applied to the Infrastruture Agent Node group, Will dynamically configure all matching nodes to allow access to key elements of Puppet Enterprise to the RSAN node
# 
# @example
#   include rsan::exporter
class rsan::exporter {



########################1.  Export Logging Function######################
# Need to determine automatically the Network Fact IP for the RSAN::importer node automatically, applies to all infrastructure nodes
#########################################################################

# Using pql to query for list of ip adresses

# Query all latest reports and show the ip address just for the rsan node

#if statement, if IP parameter left empty then assume this below

rsanip { 
  inventory[network] { class = rsan }
  }
  
  
# if fqdn if left empty then use fact. If not then use 

rsanfqdn

  
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


######################2. Metrics Dash Board deployment ###############
# Assuming use of puppet metrics dashboard for telemetry all nodes need
# include puppet_metrics_dashboard::profile::master::install
###################################################################



#####################3. Metrics Dashboard postgres access ############
# Determine if node is pe_postgres host and conditionally apply include puppet_metrics_dashboard::profile::master::postgres_access
######################################################################





#####################3. RSANpostgres command access ######################
# Determine if node is pe_postgres host and conditionally apply Select Access for the RSAN node cert to all PE databases
# Hint metrics dashboard postgres access code can be duplicated and repurposed
######################################################################











}
