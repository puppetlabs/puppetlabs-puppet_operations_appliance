# Function to provide a list of pe_postgresql hosts to the puppet_operations_appliance
# @return [Array] List of FQDN 
function puppet_operations_appliance::get_postgres_hosts() {
  $postgres_hosts =
  puppetdb_query('resources[certname] {
                    type = "Class" and
                    title = "Pe_postgresql::Server::Install" and
                    nodes {
                      deactivated is null and
                      expired is null
                    }
                  }').map |$data| { $data['certname'] }

  pe_sort($postgres_hosts)
}
