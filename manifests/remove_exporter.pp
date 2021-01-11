# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rsan::remove_exporter
class rsan::remove_exporter {


#Disable NFS Server

  class { '::nfs':
    server_enabled => false
  }

 $dbs = ['pe-activity', 'pe-classifier', 'pe-inventory', 'pe-puppetdb', 'pe-rbac', 'pe-orchestrator']
  $dbs.each |$db|{


   $dropowned_cmd = 'DROP OWNED BY rsan'
        pe_postgresql_psql { "${dropowned_cmd} on ${db}":
          command    => $dropowned_cmd,
          db         => $db,
          port       => $pe_postgresql::server::port,
          psql_user  => $pe_postgresql::server::user,
          psql_group => $pe_postgresql::server::group,
          psql_path  => $pe_postgresql::server::psql_path,
          require    => [Class['pe_postgresql::server']]
        }

      }




}
