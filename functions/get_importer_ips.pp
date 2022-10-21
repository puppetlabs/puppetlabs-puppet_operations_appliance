# @return [Array] List of IP addresses of the Puppet_operations_appliance(s) or an empty array
function rsan::get_importer_ips() {
  if $settings::storeconfigs {
    $importer_ips =
    puppetdb_query('facts[value]{
        name = "ipaddress" and
        certname in resources[certname] {
          type = "Class" and
          title = "Puppet_operations_appliance::Importer" and
          nodes {
            deactivated is null and
            expired is null
            }
          }
        }').map |$data| { $data['value'] }
  } else {
    $importer_ips = []
  }
}
