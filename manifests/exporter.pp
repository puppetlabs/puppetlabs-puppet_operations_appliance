#
# When Applied to the Infrastruture Agent Node group, 
#Will dynamically configure all matching nodes to allow access to key elements of Puppet Enterprise to the RSAN node
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

include puppet_metrics_dashboard::profile::master::install


#####################3. Metrics Dashboard postgres access ############
# Determine if node is pe_postgres host and conditionally apply include puppet_metrics_dashboard::profile::master::postgres_access
######################################################################

#The following code serves to check that postgres is present and then declares the class

if $facts['pe_postgresql_info'] != undef {
  include puppet_metrics_dashboard::profile::master::postgres_access
}



#####################3. RSANpostgres command access ######################
# Determine if node is pe_postgres host and conditionally apply Select Access for the RSAN node cert to all PE databases
# Hint metrics dashboard postgres access code can be duplicated and repurposed
######################################################################

if $facts['pe_postgresql_info'] != undef {

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

    $dbs = ['pe-activity', 'pe-classifier', 'pe-inventory', 'pe-puppetdb', 'pe-rbac', 'pe-orchestrator', 'pe-postgres']
    $dbs.each |$db|{
      pe_postgresql::server::database_grant { 'rsan':
        privilege => 'SELECT',
        db        => $db,
        role      => 'rsan',
      }
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

}









}
