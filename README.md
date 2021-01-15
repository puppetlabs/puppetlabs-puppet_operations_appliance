# rsan

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with rsan](#setup)
    * [What rsan affects](#what-rsan-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rsan](#beginning-with-rsan)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The Remote Support Access Node (RSAN) will allow Puppet support engineers to conduct live troubleshooting, resolving problems more quickly and efficiently and lead to a reduction of system disruption to the customer.  
Customers currently must deliver large volumes of data to support and resolution time is hindered by transfer logistics and privacy concerns. This same data must then be processed by internal support engineers leading to artificially decreased capacity of the support team.

The RSAN platform is designed to be a contained infrastructure endpoint in the customer Puppet Enterprise environment, collating data and access, useful in incident resolution for the target customer deployment.
The node will allow for read-only access to Puppet Entperise Component Data and configiration, and limit other access through Puppet Enterprise’s built-in Role Based Access Control(RBAC).
The Node has the functionality to make session-based outward connections towards the Puppet Support Network, controllable by the customer user in duration.


## Setup

### What rsan affects 

RSAN will Export NFS mounts of key directories from each infastruture node, while also setting up requirements for gathering of metrics and Database access for the RSAN node.
Software required for the proper functioning of the RSAN will be deployed on the target agent node.


### Setup Requirements 

#### Module Dependencies

- derdanne/nfs (>= 2.1.5)
- puppetlabs/postgresql (>= 6.6.0)
- puppetlabs/puppet_metrics_dashboard (>= 2.3.0)
- puppetlabs/stdlib (>= 4.5.0 < 7.0.0)
- puppetlabs/concat (>= 1.1.2 < 7.0.0)
- puppetlabs/transition (>= 0.1.0 < 1.0.0)
- herculesteam/augeasproviders_core (>= 2.1.5 < 4.0.0)
- herculesteam/augeasproviders_shellvar (>= 1.2.0 < 5.0.0)
- puppetlabs/apt (>= 2.0.0 < 8.0.0)
- puppet-grafana (>= 3.0.0 < 7.0.0)
- puppet-telegraf (>= 2.0.0 < 4.0.0)
- puppetlabs-apt (>= 4.3.0 < 8.0.0)
- puppetlabs-inifile (>= 2.0.0 < 5.0.0)
- puppetlabs-puppetserver_gem (>= 1.1.1 < 3.0.0)


#### Minimum Hardware requirements


| AWS EC2|Cores| RAM |Disk|
| --- | ----------- | --| --|
| m1.medium | 2 CPU | 4GB Memory | 40GB Disk 

#### OS Restrictions

RSAN will support RHEL / Debian / Ubuntu however due to the additional of PE Client tools in the installation, you are restricted to installing it on a platform with the same OS as the Primary PE Server.

### Beginning with rsan

RSAN has two main classes for use in the installation:

 - rsan::exporter - to be applied to all Puppet infrastructure agents - Console node group "PE Infrastructure Agent"
 - rsan::importer - to be applied to a single node which will be come the Remote Support Access Node(RSAN)

Following the application of these clases to the infrastructure, Puppet Will need to be run on the corresponding agents in the following order:

Infrastructure Agent(s)->RSAN Agent->Infrastrcture Agent(s)->RSAN Agent

## Usage
The following outlines the main features of RSAN and how to consume them
### Live Telemetry Display

The Rsan node will host an instance of the [Puppet Metrics Dashboard](https://forge.puppet.com/modules/puppetlabs/puppet_metrics_dashboard)
 
The Dashboard can be accessed on

**URL:** http://<RSAN-ip\>:3000\
**User:** admin\
**Password:** admin

For advanced configuration and documentation please see [Puppet Metrics Dashboard](https://forge.puppet.com/modules/puppetlabs/puppet_metrics_dashboard)

### Infrastructure node file and log access	

The RSAN node will, by default, mount `/var/log/`, `/opt/puppetlabs` and `/etc/puppetlabs` from each of the Puppet Enterprise Infrastructure nodes on the RSAN platform in the following location, as read-only file systems.

`/var/pesupport/<FQDN of Infrastructure node\>/var/log`\
`/var/pesupport/<FQDN of Infrastructure node\>/opt/puppetlabs`\
`/var/pesupport/<FQDN of Infrastructure node\>/etc/puppetlabs`

#### Optional Configuration

The RSAN Class assumes the RSAN server will mount the shared partitions using the IP address Source designated by the "ipaddress" fact. In any deployment should this assertion not be true, it is nessary to set the following parameter to the source IP address of the RSAN Host:

In Hiera 

```
rsan::exporter::rsan_importer_ips:
  - 1.2.3.4
  ```

Console Class Declaration

```
["1.2.3.4"]
```

### PE Client tools

The RSAN node will deploy Puppet Client tools for use by Puppet Enterprise on the RSAN platform, For More information please see the Puppet Enterprise Documentation:

[PE Client tools](https://puppet.com/docs/pe/2019.8/installing_pe_client_tools.html)

A supplementary task is available to generate an RBAC user and role, so that the credentials may be used provided to Puppet Enterprise Support personnel.

#### Creating Support User

Run the following task against the Primary Puppet Enterprise Server\
For information on executing PE tasks see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/2019.8/tasks_in_pe.html)\
RSAN::supportuser\
When successful the task will return a password, this should be delivered to Puppet Enterprise Support personnel.

The Task creates the following user and role:

**User:** pesupport 

**Role:** PE Suport Role 

The role is intentonally left without permissions, and should be given only the permissions the installing organisation are authorised to grant to Puppet Enterprise Support personnel. For more information on RBAC permissions please see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/2019.8/rbac_permissions_intro.html)

### Puppet Enterprise Database Access	

The RSAN Platform has a Postgresql client installed, and is granted certificate based access to all Puppet Enterprise Databases on any pe_postgresl node within the current deployment. The access is limited to the [SELECT](https://www.postgresql.org/docs/11/sql-grant.html) privilege and is therefore READONLY in nature.

To use this function execute the following command from the CLI of the RSAN host

```
psql "host=$(puppet config print server) port=5432 user=rsan sslmode=verify-full sslcert=$(puppet config print hostcert) sslkey=$(puppet config print hostprivkey) sslrootcert=$(puppet config print localcacert) dbname=<pe_db_name>"
```

Where valid options for <pe_db_name> are:

- pe-rbac 
- pe-puppetdb 
- pe-orchestrator 
- pe-inventory 
- pe-classifier 
- pe-activity

## Uninstallation 

To Uninsuall RSAN from your Puppet Enterprise Infrastructure.

 - Remove the following Classification:
rsan::exporter\
rsan::importer

 - Add the following classification to the "PE Infrastructure Agent" node group
 rsan::remove_exporter

  - Remove the following classification to the "PE Infrastructure Agent" node group
 rsan::remove_exporter

  - Run Puppet on all nodes in "PE Infrastructure Agent" node group

   - Decommission the RSAN platform 


## Limitations
 - The RSAN importer class should only be applied one agent node
 - All features are currently enabled and can not be individually disabled, this will be addressed in future releases

## Known Issues

- When accessing the database from the RSAN node for the first time, an error message will be presented: [#40](https://github.com/MartyEwings/RSAN/issues/40)

```psql: private key file "/etc/puppetlabs/puppet/ssl/private_keys/rsan-target.platform9.puppet.net.pem" has group or world access; permissions should be u=rw (0600) or less```

 To workaround change the private key file to 0600 or less, Puppet will manage this file back to incorrect permissions, for long term access making a copy of the key with the correct permissions is the best course of action. 

 - PuppetDB Metric Collection fails due to CVE-2020-7943  [27](https://github.com/MartyEwings/RSAN/issues/27)

Please refer to the documenation of Puppet Metrics collector for recommended work arounds

 - RSAN NFS volumes are mounted RW, but exported RO  [26](https://github.com/MartyEwings/RSAN/issues/26)
 
 There is no impact to the end user

## Contributions

For feature development + bug reporting:

 - A Git Issue should exist or be created per feature or Bug
 - Repositary should be forked and any changes made by way of PR to the Main Branch
 - PRS should aways reference a git issue
