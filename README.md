# Puppet Operations Appliance

#### Table of Contents

- [Puppet Operations Appliance](#puppet-operations-appliance)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [What Puppet_Operations_Appliance modifies in your PE Installation](#what-puppet_operations_appliance-modifies-in-your-pe-installation)
    - [Setup Requirements](#setup-requirements)
      - [Module Dependencies](#module-dependencies)
      - [Minimum Hardware requirements](#minimum-hardware-requirements)
      - [OS Restrictions](#os-restrictions)
    - [Beginning with Puppet_Operations_Appliance](#beginning-with-puppet_operations_appliance)
  - [Usage](#usage)
    - [Live Telemetry Display](#live-telemetry-display)
    - [Infrastructure node file and log access](#infrastructure-node-file-and-log-access)
      - [Optional Configuration](#optional-configuration)
    - [PE Client tools](#pe-client-tools)
      - [Creating Support User](#creating-support-user)
    - [Puppet Enterprise Database Access](#puppet-enterprise-database-access)
  - [Uninstallation](#uninstallation)
  - [Limitations](#limitations)
  - [Known Issues](#known-issues)
  - [Contributions](#contributions)


## Description

The Puppet Operations Appliance is designed to be a central point to which a Puppet Enterprise environment may be monitored and maintained.
The appliance collates data and provides read-only access, useful in incident resolution and preventative maintenance.


## Setup

### What Puppet_Operations_Appliance modifies in your PE Installation 

Puppet_Operations_Appliance will Export NFS mounts of key directories from each Puppet Enterprise infrastructure node, while also setting up requirements for gathering of metrics and database access for the Puppet_Operations_Appliance.
Open-source software required for the proper functioning of the Puppet_Operations_Appliance will be deployed on the target agent node.


### Setup Requirements 

#### Module Dependencies

- derdanne/nfs (>= 2.1.5)
- puppetlabs/postgresql (>= 6.6.0)
- puppetlabs/puppet_operational_dashboards (>= 1.7.0)
- puppetlabs/influxdb  (>=1.3.1)
- puppetlabs/stdlib (>= 4.5.0 < 9.0.0)
- puppetlabs/concat (>= 1.1.2 < 7.0.0)
- puppetlabs/transition (>= 0.1.0 < 1.0.0)
- puppet/augeasproviders_core (>= 2.1.5 < 4.0.0)
- puppet/augeasproviders_shellvar (>= 1.2.0 < 5.0.0)
- puppetlabs/apt (>= 2.0.0 < 8.0.0)
- puppet-grafana (>= 3.0.0 < 11.0.0)
- puppet-telegraf (>= 2.0.0 < 6.0.0)
- puppetlabs-apt (>= 4.3.0 < 9.0.0)
- puppetlabs-inifile (>= 2.0.0 < 5.0.0)

#### Minimum Hardware requirements


| AWS EC2|Cores| RAM |Disk|
| --- | ----------- | --| --|
| m1.medium | 2 CPU | 4GB Memory | 40GB Disk 

#### OS Restrictions

Puppet_Operations_Appliance will support RHEL / Debian / Ubuntu however due to the additional of PE Client tools in the installation, you are restricted to installing it on a platform with the same OS as the Primary PE Server.

### Beginning with Puppet_Operations_Appliance

Puppet_Operations_Appliance has two main classes for use in the installation:

 - Puppet_Operations_Appliance::exporter - to be applied to all Puppet infrastructure agents - Console node group "PE Infrastructure Agent"
 - Puppet_Operations_Appliance::importer - to be applied to a single node which will be come the Puppet Operations Appliance.

Following the application of these classes to the infrastructure, Puppet Will need to be run on the corresponding agents in the following order:

Infrastructure Agent(s)->Puppet_Operations_Appliance Agent->Infrastructure Agent(s)->Puppet_Operations_Appliance Agent

## Usage
The following outlines the main features of Puppet_Operations_Appliance and how to consume them
### Live Telemetry Display

The Puppet_Operations_Appliance node will host an instance of the [Puppet Operational Dashboard](https://forge.puppet.com/modules/puppetlabs/puppet_operational_dashboards)
 
The Dashboard can be accessed on

**URL:** http://<Puppet_Operations_Appliance-ip\>:3000\
**User:** admin\
**Password:** admin

For advanced configuration and documentation please see [Puppet Operational Dashboard](https://forge.puppet.com/modules/puppetlabs/puppet_operational_dashboards)

### Infrastructure node file and log access	

The Puppet_Operations_Appliance node will, by default, mount `/var/log/`, `/opt/puppetlabs` and `/etc/puppetlabs` from each of the Puppet Enterprise Infrastructure nodes on the Puppet_Operations_Appliance in the following location, as read-only file systems.

`/var/pesupport/<FQDN of Infrastructure node\>/var/log`\
`/var/pesupport/<FQDN of Infrastructure node\>/opt/puppetlabs`\
`/var/pesupport/<FQDN of Infrastructure node\>/etc/puppetlabs`

#### Optional Configuration

The Puppet_Operations_Appliance Class assumes the Puppet_Operations_Appliance server will mount the shared partitions using the IP address Source designated by the "ipaddress" fact. In any deployment should this assertion not be true, it is necessary to set the following parameter to the source IP address of the Puppet_Operations_Appliance Host:

In Hiera 

```
puppet_operations_appliance::exporter::importer_ips:
  - 1.2.3.4
  ```

Console Class Declaration

```
["1.2.3.4"]
```

The Puppet_Operations_Appliance::Exporter class allows for the NFS mounts to be optionally available, to disable existing mounts, or prevent the mounts from installing in the first place set the following parameter:


In Hiera

```
puppet_operations_appliance::exporter::nfsmount: false
```

### PE Client tools

The Puppet_Operations_Appliance node will deploy Puppet Client tools for use by Puppet Enterprise on the Puppet_Operations_Appliance platform, For More information please see the Puppet Enterprise Documentation:

[PE Client tools](https://puppet.com/docs/pe/latest/installing_pe_client_tools.html)

A supplementary task is available to generate an RBAC user and role, so that the credentials may be used provided to Puppet Enterprise Support personnel.  
<br>
#### Creating Support User  
<br>
Run the following task against the Primary Puppet Enterprise Server\
For information on executing PE tasks see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/latest/tasks_in_pe.html)\
Puppet_Operations_Appliance::supportuser\
When successful the task will return a password, this should be delivered to Puppet Enterprise Support personnel.
<br>
<br>
The Task creates the following user and role:
<br>
<br>

**User:** pesupport 

**Role:** PE Support Role 

The role is intentionally left without permissions, and should be given only the permissions the installing organisation are authorised to grant to Puppet Enterprise Support personnel. For more information on RBAC permissions please see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/latest/rbac_permissions_intro.html)

### Puppet Enterprise Database Access	

The Puppet_Operations_Appliance Platform has a Postgresql client installed, and is granted certificate based access to all Puppet Enterprise Databases on any pe_postgresl node within the current deployment. The access is limited to the [SELECT](https://www.postgresql.org/docs/11/sql-grant.html) privilege and is therefore READONLY in nature.

To use this function execute the following command from the CLI of the Puppet_Operations_Appliance host

```
psql "host=$(puppet config print server) port=5432 user=puppet_operations_appliance sslmode=verify-full sslcert=$(puppet config print hostcert) sslkey=$(puppet config print hostprivkey) sslrootcert=$(puppet config print localcacert) dbname=<pe_db_name>"
```

Where valid options for <pe_db_name> are:

- pe-rbac 
- pe-puppetdb 
- pe-orchestrator 
- pe-inventory 
- pe-classifier 
- pe-activity

## Uninstallation 

To Uninstall Puppet_Operations_Appliance from your Puppet Enterprise Infrastructure.


 - Remove the following Classification:
Puppet_Operations_Appliance::exporter\
Puppet_Operations_Appliance::importer

 - Add the following classification to the "PE Infrastructure Agent" node group
 Puppet_Operations_Appliance::remove_exporter

  - Remove the following classification to the "PE Infrastructure Agent" node group
 Puppet_Operations_Appliance::remove_exporter

  - Run Puppet on all nodes in "PE Infrastructure Agent" node group

   - Decommission the Puppet_Operations_Appliance platform 


## Limitations
 - The Puppet_Operations_Appliance importer class should only be applied one agent node

## Known Issues

 - Puppet_Operations_Appliance NFS volumes are mounted RW, but exported RO  [26](https://github.com/puppetlabs/Puppet_Operations_Appliance/issues/26)
 
 There is no impact to the end user

## Contributions

For feature development + bug reporting:

 - A Git Issue should exist or be created per feature or Bug
 - Repository should be forked and any changes made by way of PR to the Main Branch
 - PRS should always reference a git issue
