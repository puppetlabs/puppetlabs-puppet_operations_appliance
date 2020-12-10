function rsan::get_postgres_hosts() {
    $postgres_hosts =
                puppetdb_query('resources[certname] {
                    type = "Class" and
                    title = "Pe_postgresql::Server::Install" and
                    nodes {
                      deactivated is null and
                      expired is null
                    }
                  }').map |$data| { $data['certname'] }
  }

  pe_sort($postgres_hosts)


