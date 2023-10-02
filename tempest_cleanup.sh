#!/bin/bash

servers=$(openstack server list -c Name -c ID | grep tempest | awk '{print $2}')


# server cleanup
for server in $servers; do 
    openstack server delete $server

    if openstack server list | grep -q "$server"; then
	echo "server $server has been deleted"
    else
	echo "server $server has not been deleted"
    fi
done


# FIP & ports cleanup 
ports=$(openstack floating ip list -c ID -c Port | grep -v -e '^$' -e ID -e Port -e None | awk '{print $4}')

for port in $ports; do
    network=$(openstack port show $port | grep network_id | awk '{print $4}')
    if openstack network show $network -c name | grep tempest; then
        openstack floating ip delete $(openstack floating ip list | grep $port | awk '{print $2}')
	
	if openstack port delete $port; then
	    router=$(openstack port show $port | grep device_id | awk '{print $4}')
            
            ports_of_router=$(openstack router show $router | grep interfaces_info | grep -oE '\"port_id\":\s\"[0-9a-zA-Z\-]+\"' | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")

	    for port in $ports_of_router; do
		openstack router remove port $router $port; 
	    done
            for port in $ports_of_router; do
		openstack port delete $port;
	    done
       	fi
    fi
done


# security group cleanup 

security_groups=$(openstack security group list | grep tempest | awk '{print $2}')

for sg in $security_groups; do
    openstack security group delete $sg;
done



# nets=$(for port in $ports; do    openstack port show $port | grep network_id | grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'; done)


