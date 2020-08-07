#!/bin/sh

# Puppet Task Name: rsan
#
# Learn more at: https://puppet.com/docs/bolt/0.x/writing_tasks.html#ariaid-title11
#

#
# shellcheck disable=SC2046

declare PT_rsannode
rsannode=$PT_rsannode

mom=$(hostname -f)
rsanip=$(curl -X GET http://localhost:8080/pdb/query/v4/facts/ipaddress   --data-urlencode "query=[\"=\", \"certname\", \"$rsannode\"]" | awk -v RS='([0-9]+\\.){3}[0-9]+' 'RT{print RT}')
infranodes=($(puppet query "nodes[certname] { resources { type = 'Class' and title = 'Puppet_enterprise::Profile::Master' or type = 'Class' and title = 'puppet_enterprise::profile::primary_master_replica'} and certname !='$(hostname -f)'  }" --urls http://localhost:8080 | sed -e 's/[{}]/''/g' |      awk -v k="text" '{n=split($0,a,":"); for (i=1; i<=n; i++) print a[i+1]}' | sed '/^$/d'))

#inodes=$(printf "$mom ,[%s] " "${infranodes[@]/%/, 8140}")

inodes=$(printf ",[%s]" "${infranodes[@]/%/, 8140}")
classinodes=$(echo "[""\""$mom"\""$inodes"]")



if [ -e "/etc/sysconfig/pe-puppetserver" ] # Test to confirm this is a Puppetserver
then
  echo "Puppet master node detected"   #Log Line to StdOut for the Console







############## Create pesupport User and role for use in client tools##########
###############################################################################

password=$(/opt/puppetlabs/puppet/bin/openssl rand -base64 32) #Set Random Password for Support Client tools account

curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/users -d "{\"login\":\"pesupport\",\"email\":\"support@puppet.com\",\"role_ids\": [],\"display_name\":\"Puppet Enterprise Support\", \"password\": \"$password\"}"

echo "password for pesupport account is $password"

peusersid=$(curl -X get -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/users|sed -e 's/[{}]/''/g' |      awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) {if (a[i]=="\"login\":\"pesupport\""){ print a[i+2]}}}' | awk '{split($0,a,"\""); print a[4]}') #get the SID of the new user to use in adding a role


curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/rbac-api/v1/roles -d "{\"description\":\"Puppet Enterprise Support user role\",\"display_name\":\"PE Suport Role\",\"user_ids\":[\"$peusersid\"],\"group_ids\":[],\"permissions\":[{\"object_type\":\"node_groups\",\"action\":\"modify_children\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"set_environment\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"view\",\"instance\":\"*\"},{\"object_type\":\"puppet_agent\",\"action\":\"run\",\"instance\":\"*\"},{\"object_type\":\"environment\",\"action\":\"deploy_code\",\"instance\":\"*\"},{\"object_type\":\"nodes\",\"action\":\"view_data\",\"instance\":\"*\"},{\"object_type\":\"node_groups\",\"action\":\"edit_config_data\",\"instance\":\"*\"},{\"object_type\":\"orchestrator\",\"action\":\"view\",\"instance\":\"*\"}]}"  #create role add user




############## create and classify node group for rsan node 
###############################################################################

curl -X PUT -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/classifier-api/v1/groups/72fef894-4a71-473a-9e54-c94a2805ddd9 -d "{\"name\":\"RemoteSupportAccess\",\"parent\":\"00000000-0000-4000-8000-000000000000\",\"classes\": {\"rsan\":{\"pdb\":\"$mom\",\"infranode\":$classinodes}}}"

echo "RemoteSupportAccess group created"

curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/classifier-api/v1/groups/72fef894-4a71-473a-9e54-c94a2805ddd9/pin -d {\"nodes\":[\"$rsannode\"]}

echo "$rsannode has been pined to group"



#######master node classify and pin

curl -X PUT -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/classifier-api/v1/groups/7434a707-7104-4142-85b8-5404768a841a -d "{\"name\":\"RSANMaster\",\"parent\":\"00000000-0000-4000-8000-000000000000\",\"classes\": {\"rsan::master\":{\"rsanip\":\"$rsanip\"}}}"

echo "RSANMaster  group created"

curl -X POST -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/classifier-api/v1/groups/7434a707-7104-4142-85b8-5404768a841a/pin -d {\"nodes\":[\"$mom\"]}

echo "$mom has been pined to group"

######infra nodes classify and pin

curl -X PUT -H 'Content-Type: application/json' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname -f):4433/classifier-api/v1/groups/8882255f-26d9-47cf-a6e4-5b9075d30703 -d "{\"name\":\"RSANInfra\",\"parent\":\"00000000-0000-4000-8000-000000000000\",\"rule\": [\"=\", [\"trusted\",\"extensions\", \"pp_auth_role\"], \"pe_compiler\"],\"classes\": {\"rsan::infrastructure\":{\"rsanip\":\"$rsanip\"}}}"


echo "RSANInfra  group created"
echo "PE_Compilers will automatically be classified, please pin any Replicas or Legacy compilers to this group manually"


else
  echo  "Not a Puppet Enterprise Master node, exiting"

fi
