function rsan::get_postgres_hosts() {
  if $settings::storeconfigs {
    $postgres_hosts =
                puppetdb_query('resources[certname] {
                    type = "Class" and
                    title = "pe_postgresql::server::install" and
                    nodes {
                      deactivated is null and
                      expired is null
                    }
                  }').map |$data| { $data['certname'] }
  } else {
    $postgres_hosts = []
  }

  pe_sort($postgres_hosts)

}
