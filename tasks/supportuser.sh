#!/bin/sh

# Puppet Task Name: supportuser
#
password=$(/opt/puppetlabs/puppet/bin/openssl rand -base64 32) #Set Random Password for Support Client tools account

curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/users -d "{\"login\":\"pesupport\",\"email\":\"support@puppet.com\",\"role_ids\": [],\"display_name\":\"Puppet Enterprise Support\", \"password\": \"$password\"}"

echo "password for pesupport account is $password"

peusersid=$(curl -X get -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/users|sed -e 's/[{}]/''/g' |      awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) {if (a[i]=="\"login\":\"pesupport\""){ print a[i+2]}}}' | awk '{split($0,a,"\""); print a[4]}') #get the SID of the new user to use in adding a role


curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/roles -d "{\"description\":\"Puppet Enterprise Support user role\",\"display_name\":\"PE Suport Role\",\"user_ids\":[\"$peusersid\"],\"group_ids\":[],\"permissions\":[{\"object_type\":\"node_groups\",\"action\":\"modify_children\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"set_environment\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"view\",\"instance\":\"*\"},{\"object_type\":\"puppet_agent\",\"action\":\"run\",\"instance\":\"*\"},{\"object_type\":\"environment\",\"action\":\"deploy_code\",\"instance\":\"*\"},{\"object_type\":\"nodes\",\"action\":\"view_data\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"edit_config_data\",\"instance\":\"*\"},{\"object_type\":\"orchestrator\",\"action\":\"view\",\"instance\":\"*\"}]}"  #create role add user

