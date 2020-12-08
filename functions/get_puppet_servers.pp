function rsan::get_puppet_servers() {
  $puppet_servers =
          puppetdb_query("nodes[certname] {
                     resources {
                         type = 'Class' and
                         title = 'Puppet_enterprise::Profile::Master'
                     } and deactivated is null and expired is null }").map |$node| {
                        $node['certname']
                    }
  pe_sort($puppet_servers)
}
