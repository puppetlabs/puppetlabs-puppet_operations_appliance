# @return [Array] List of IP addresses for RSAN nodes or an empty array
function rsan::get_rsan_importer_ips() {
  if $settings::storeconfigs {
    $rsan_importer_ips =
    puppetdb_query('facts[value]{
        name = "ipaddress" and
        certname in resources[certname] {
          type = "Class" and
          title = "Rsan::Importer" and
          nodes {
            deactivated is null and
            expired is null
            }
          }
        }').map |$data| { $data['value'] }
  } else {
    $rsan_importer_ips = []
  }
}
