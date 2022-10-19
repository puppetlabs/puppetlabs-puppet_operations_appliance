# @summary disables and removes services and components enabled by the exporter class
#
# In the event RSAN should be uninstalled on all or some of the exporter nodes,
# this will stop NFS service, and remove the database components if applied to a postgres node
#
# @example
#   include rsan::remove_exporter
class rsan::remove_exporter {
  #Disable NFS Server 

  service { 'nfs-server':
    ensure => stopped,
  }

  if $facts['pe_postgresql_info'] != undef and $facts['pe_postgresql_info']['installed_server_version'] != '' {
    $dbs = ['pe-activity', 'pe-classifier', 'pe-inventory', 'pe-puppetdb', 'pe-rbac', 'pe-orchestrator']
    $dbs.each |$db| {
      $dropowned_cmd = 'DROP OWNED BY rsan'
      pe_postgresql_psql { "${dropowned_cmd} on ${db}":
        command    => $dropowned_cmd,
        db         => $db,
        port       => $pe_postgresql::server::port,
        psql_user  => $pe_postgresql::server::user,
        psql_group => $pe_postgresql::server::group,
        psql_path  => $pe_postgresql::server::psql_path,
        require    => [Class['pe_postgresql::server']],
      }
    }

    $droprole_cmd = 'DROP ROLE rsan'
    pe_postgresql_psql { "${droprole_cmd}  ":
      command    => $droprole_cmd,
      db         => pe-puppetdb,
      port       => $pe_postgresql::server::port,
      psql_user  => $pe_postgresql::server::user,
      psql_group => $pe_postgresql::server::group,
      psql_path  => $pe_postgresql::server::psql_path,
      require    => Pe_postgresql_psql['DROP OWNED BY rsan on pe-puppetdb'],
    }
  }
}
