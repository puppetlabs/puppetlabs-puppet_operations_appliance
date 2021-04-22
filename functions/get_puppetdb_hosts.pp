
# @return [Array] List of node running Puppetdb
function rsan::get_puppetdb_hosts() {
  if $settings::storeconfigs {
    $puppetdb_hosts =
                puppetdb_query('resources[certname] {
                    type = "Class" and
                    title = "Puppet_enterprise::Profile::Puppetdb" and
                    nodes {
                      deactivated is null and
                      expired is null
                    }
                  }').map |$data| { $data['certname'] }
  } else {
    $puppetdb_hosts = []
  }

  pe_sort($puppetdb_hosts)
}
