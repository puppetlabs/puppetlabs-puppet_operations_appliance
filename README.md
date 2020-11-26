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
Dependencies

derdanne/nfs (>= 2.1.5)
puppetlabs/postgresql (>= 6.6.0)
puppetlabs/puppet_metrics_dashboard (>= 2.3.0)
puppetlabs/stdlib (>= 4.5.0 < 7.0.0)
puppetlabs/concat (>= 1.1.2 < 7.0.0)
puppetlabs/transition (>= 0.1.0 < 1.0.0)
herculesteam/augeasproviders_core (>= 2.1.5 < 4.0.0)
herculesteam/augeasproviders_shellvar (>= 1.2.0 < 5.0.0)
puppetlabs/apt (>= 2.0.0 < 8.0.0)
puppet-grafana (>= 3.0.0 < 7.0.0)
puppet-telegraf (>= 2.0.0 < 4.0.0)
puppetlabs-apt (>= 4.3.0 < 8.0.0)
puppetlabs-inifile (>= 2.0.0 < 5.0.0)
puppetlabs-puppetserver_gem (>= 1.1.1 < 3.0.0)
puppet/openvpn (>= 8.3.0)




### Beginning with rsan

RSAN has Two Classes:

 - rsan::exporter - to be applied to all Puppet infrastructure agents - Console node group "PE Infrastructure Agent"
 - rsan::importer - to be applied to a single node which will be come the Remote Support Access Node

Adding these two classes will set up all applications and configurations to run  RSAN

## Usage

TBC - detailed description of feature switches and configurable parameters

## Limitations



## Contributions

For feature development + bug reporting:

 - A Git Issue should exist or be created per feature or Bug
 - Repositary should be forked and any changes made by way of PR to the Main Branch
 - PRS should aways reference a git issue
