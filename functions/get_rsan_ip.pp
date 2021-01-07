function rsan::get_rsan_ip() {
  if $settings::storeconfigs {
    $rsan_ip =
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
        }').map |$data| { $data['certname'] }
  } else {
    $rsan_ip = []
  }
