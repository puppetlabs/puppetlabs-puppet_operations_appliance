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

This Module enables a proof of concept (POC) installation of a Remote Support Access Node(RSAN).  

The purpose of the Remote Support Access Node is to enable a server that is used to provide a live view of Logs, Metrics, and Configuration data within a Puppet Enterprise Infrastructure.
When customers allow remote access to the RSAN available for Puppet support engineers to conduct live troubleshooting, problems are more quickly and easily identified reducing system disruption for the customer.  
Remote Support Access Node Functions

* Mount designated folders from Puppet infrastructure components as read-only to the Support remote access node.
* PE Client tools deployed, RBAC restricted to a few functions and specific audited tasks, access is controlled by the customer
* Grafana Metrics Dashboard
* Read access to Live Postgres Database


## Setup

### What rsan affects 

RSAN will create a series of nodegroups in the Puppet Enterprise classifier for infrastructure nodes, and will apply several classes to these nodes.

### Setup Requirements 
Dependencies

derdanne/nfs (>= 2.1.5)
puppetlabs/postgresql (>= 6.6.0)
puppetlabs/puppet_metrics_collector (>= 6.1.0)
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




### Beginning with rsan

A new Puppet agent node of the same operating System as the Master should be configured with access to the same network as the Puppet Enterprise Infrastructure components.
This node will be referred to as the RSAN going forward.


## Usage

Run Installation Task From the Puppet Enterprise Console run the RSAN task provided by the RSAN module;

* Target Should be the MOM
* Parameter rsannode is the FQDN of the RSAN agent


## Limitations

Tested in Version 2019.8.1
Currently no error handling in the installation task
No access to databases other than pe-postgres


