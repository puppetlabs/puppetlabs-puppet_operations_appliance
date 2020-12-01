#
# When Applied to the Infrastruture Agent Node group, Will dynamically configure all matching nodes to allow access to key elements of Puppet Enterprise to the RSAN node
# 
# @example
#   include rsan::exporter
class rsan::exporter {



########################1.  Export Logging Function######################
# Need to determine automatically the Network Fact IP for the RSAN::importer node automatically, applies to all infrastructure nodes
#########################################################################




######################2. Metrics Dash Board deployment ###############
# Assuming use of puppet metrics dashboard for telemetry all nodes need
# include puppet_metrics_dashboard::profile::master::install
###################################################################



#####################3. Metrics Dashboard postgres access ############
# Determine if node is pe_postgres host and conditionally apply include puppet_metrics_dashboard::profile::master::postgres_access
######################################################################

#The following code serves to check that postgres is present. No action taken apart from message printed.

if $pe_postgresql_info != undef {
  notify { "postgres is present, applying class" }
  include puppet_metrics_dashboard::profile::master::postgres_access
} else {
  notify { "postgres is not present"
}




#####################3. RSANpostgres command access ######################
# Determine if node is pe_postgres host and conditionally apply Select Access for the RSAN node cert to all PE databases
# Hint metrics dashboard postgres access code can be duplicated and repurposed
######################################################################











}
