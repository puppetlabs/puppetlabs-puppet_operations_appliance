# rsan

#### Table of Contents

- [rsan](#rsan)
      - [Table of Contents](#table-of-contents)
  - [RSAN is currently part of a Beta Program](#rsan-is-currently-part-of-a-beta-program)
  - [Description](#description)
  - [Setup](#setup)
    - [What RSAN modifies in your PE Installation](#what-rsan-modifies-in-your-pe-installation)
    - [Setup Requirements](#setup-requirements)
      - [Module Dependencies](#module-dependencies)
      - [Minimum Hardware requirements](#minimum-hardware-requirements)
      - [OS Restrictions](#os-restrictions)
    - [Beginning with rsan](#beginning-with-rsan)
    - [Setup VPN client with profile](#setup-vpn-client-with-profile)
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


## RSAN is currently part of a Beta Program

The Puppet Enterprise Support team is opening an exciting Beta to help us remove some obstacles our customers have reported when engaging the Support Team for incident resolution.
The Remote Support Service Beta is a combination of a Service provided by the Support team and Puppet Module named RSAN (Remote Support Access Node).
Puppet Enterprise Support will work with you to see how your organization can access the RSAN deployment and how that process should be implemented. , Currently we have two access options; direct as an incoming VPN connection from the Puppet Support Member, or a simple screen share on the video conferencing software of your choice.

How you can get involved


As an existing Puppet Enterprise customer with access to the [Support Portal](http://support.puppet.com), open a Priority 4 ticket with the subject  “Participate in the RSAN beta” and a support engineer will engage with you regarding access methods and any help installing the module you may need.


## Description

The Remote Support Access Node (RSAN) will allow Puppet support engineers to conduct live troubleshooting, resolving problems more quickly and efficiently and lead to a reduction of system disruption to the customer.  
Customers currently must deliver large volumes of data to support and resolution time is hindered by transfer logistics and privacy concerns. This same data must then be processed by internal support engineers leading to artificially decreased capacity of the support team.

The RSAN platform is designed to be a contained infrastructure endpoint in the customer Puppet Enterprise environment, collating data and access, useful in incident resolution for the target customer deployment.
The node will allow for read-only access to Puppet Enterprise Component Data and configuration, and limit other access through Puppet Enterprise’s built-in Role Based Access Control(RBAC).


## Setup

### What RSAN modifies in your PE Installation 

RSAN will Export NFS mounts of key directories from each infrastructure node, while also setting up requirements for gathering of metrics and Database access for the RSAN node.
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
 - rsan::importer - to be applied to a single node which will become the Remote Support Access Node(RSAN)

Following the application of these classes to the infrastructure, Puppet Will need to be run on the corresponding agents in the following order:

Infrastructure Agent(s)->RSAN Agent->Infrastructure Agent(s)->RSAN Agent

### Setup VPN client with profile

RSAN comes with `rsan::openvpn_client` class that when classified to the RSAN node it will:

  - Install OpenVPN client on RSAN node
  - Connect to Puppet's OpenVPN server and obtain customer VPN profile using customer's UUID
  - Creates a service that will initiate a VPN connection from RSAN to Puppet's OpenVPN server using customer's VPN profile when started
  - Places openvpnconnection.sh backup bash script on the RSAN node for manual execution

RSAN OpenVPN client requirements:

  1. Outbound HTTPS port 443 from RSAN node to Puppet's OpenVPN server to obtain customer's VPN profile
  2. Outbound TCP port 943 from RSAN node to Puppet's OpenVPN server to establish vpn connection

RSAN VPN connection will be initiated and terminated from the console by using the standard Puppet `package::linux` Task for `openvpn@puppet` RSAN service created by `rsan::openvpn_client` class. In the eventuality that the previously mentioned task cannot be initiated from the console, use `/etc/openvpn/openvpnconnection.sh` to initiate vpn client connection utilising a previously downloaded customer's VPN profile.

Once a VPN connection has been successfully established between RSAN node and Puppet's OpenVPN server, a Puppet's Support Engineer will be able to log onto the RSAN node using a similar connection to the same VPN network.

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

The RSAN Class assumes the RSAN server will mount the shared partitions using the IP address Source designated by the "ipaddress" fact. In any deployment should this assertion not be true, it is necessary to set the following parameter to the source IP address of the RSAN Host:

In Hiera 

```
rsan::exporter::rsan_importer_ips:
  - 1.2.3.4
  ```

Console Class Declaration

```
["1.2.3.4"]
```

The RSAN::Exporter class allows for the NFS mounts to be optionally available, to disable existing mounts, or prevent the mounts from installing in the first place set the following parameter:


In Hiera

```
rsan::exporter::nfsmount: false
```

### PE Client tools

The RSAN node will deploy Puppet Client tools for use by Puppet Enterprise on the RSAN platform, For More information please see the Puppet Enterprise Documentation:

[PE Client tools](https://puppet.com/docs/pe/2019.8/installing_pe_client_tools.html)

A supplementary task is available to generate an RBAC user and role, so that the credentials may be used provided to Puppet Enterprise Support personnel.  
<br>
#### Creating Support User  
<br>
Run the following task against the Primary Puppet Enterprise Server\
For information on executing PE tasks see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/2019.8/tasks_in_pe.html)\
RSAN::supportuser\
When successful the task will return a password, this should be delivered to Puppet Enterprise Support personnel.
<br>
<br>
The Task creates the following user and role:
<br>
<br>

**User:** pesupport 

**Role:** PE Suport Role 

The role is intentionally left without permissions, and should be given only the permissions the installing organisation are authorised to grant to Puppet Enterprise Support personnel. For more information on RBAC permissions please see the [Puppet Enterprise Documentation](https://puppet.com/docs/pe/2019.8/rbac_permissions_intro.html)

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

To Uninstall RSAN from your Puppet Enterprise Infrastructure.


 - Remove the following Classification:
rsan::exporter\
rsan::importer
rsan::openvpn_client


 - Add the following classification to the "PE Infrastructure Agent" node group
 rsan::remove_exporter

  - Remove the following classification to the "PE Infrastructure Agent" node group
 rsan::remove_exporter

  - Run Puppet on all nodes in "PE Infrastructure Agent" node group

   - Decommission the RSAN platform 


## Limitations
 - The RSAN importer class should only be applied one agent node
 - All features are currently enabled and can not be individually disabled, this will be addressed in future releases
 - If `rsan::openvpn_client` classified to a RHEL RSAN node, EPEL Repository needs to be added to the node prior
  to applying the class in order to successfully install `openvpn` client software.


## Known Issues

 - PuppetDB Metric Collection fails due to CVE-2020-7943  [27](https://github.com/puppetlabs/RSAN/issues/27)

Please refer to the documentation of Puppet Metrics Dashboard for recommended work arounds

 - RSAN NFS volumes are mounted RW, but exported RO  [26](https://github.com/puppetlabs/RSAN/issues/26)
 
 There is no impact to the end user

## Contributions

For feature development + bug reporting:

 - A Git Issue should exist or be created per feature or Bug
 - Repository should be forked and any changes made by way of PR to the Main Branch
 - PRS should always reference a git issue
