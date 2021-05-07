# Function to return a list of components running pe_puppetserver to RSAN
# @return [Array] List of Fqdn of nodes with the Master profile
function rsan::get_puppet_servers() {
  $puppet_servers =
          puppetdb_query('nodes[certname] {
                     resources {
                         type = "Class" and
                         title = "Puppet_enterprise::Profile::Master"
                     } and deactivated is null and expired is null }').map |$node| {
                        $node['certname']
                    }
  pe_sort($puppet_servers)
}
