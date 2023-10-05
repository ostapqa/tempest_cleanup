#!/bin/bash

source /home/ostap/Desktop/sasha-source



# server cleanup
servers=$(openstack server list -c Name -c ID | grep tempest | awk '{print $2}')

for server in $servers; do 
    openstack server delete $server

    if openstack server list | grep -q "$server"; then
	echo "server $server has been deleted"
    else
	echo "server $server has not been deleted"
    fi
done



# FIP & ports cleanup 
ports=$(openstack port list -c ID | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
subnets=$(openstack port list | grep -oE "subnet_id='[a-zA-Z0-9\-]+'" | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")

subnets_tempest=$(for subnet in $subnets; do    if openstack subnet show $subnet | grep tempest; then echo "$subnet"; fi done | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}" | uniq)


for subnet in $subnets_tempest; do
    ports=$(openstack port list | grep $subnet | awk '{print $2}')

        echo "attempt to delete fip of $port"
	openstack floating ip delete $(openstack floating ip list | grep $port | awk '{print $2}');

    for port in $ports; do
        echo "attempt to delete subnet $subnet"
        openstack subnet delete $subnet

	echo "attempt to delete fip of $port"
        openstack floating ip delete $(openstack floating ip list | grep $port | awk '{print $2}');

	    
	echo "attempt to delete $port"
        if ! openstack port delete $port; then
            echo "port $port has not been deleted, attempt to delete common entities"

	    router=$(openstack port show $port | grep device_id | awk '{print $4}')

            ports_of_router=$(openstack router show $router | grep interfaces_info | grep -oE '\"port_id\":\s\"[0-9a-zA-Z\-]+\"' | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
        else
	    echo "port $port has been deleted"
       	fi

        for port in $ports_of_router; do
	    if openstack router remove port $router $port; then
                echo "port $port has been removed from $router"
            fi
        done

        for port in $ports_of_router; do
            echo "attempt to delete $port"
            if openstack port delete $port; then
                echo "port $port has been deleted"
          
            else
	        echo "port $port has not been deleted"
            fi
        done
 
 	echo "attempt to delete subnet $subnet"
        openstack subnet delete $subnet

    done
done




# security group cleanup 

security_groups=$(openstack security group list | grep tempest | awk '{print $2}')

for sg in $security_groups; do
    openstack security group delete $sg;
done


# networks & subnetworks cleanup

subnets=$(openstack subnet list | grep tempest | awk '{print $4}')
networks=$(openstack network list | grep tempest | awk '{print $4}')


for subnet in $sunbets; do
    openstack subnet delete $subnet;
done

for net in $networks; do
    openstack network delete $network;
done



# volume&flavor cleanup

volumes=$(openstack volume list | grep tempest | awk '{print $2}')
volume_types=$(openstack volume type list | grep tempest | awk '{print $2}')

for volume in $volumes; do
    openstack volume delete $volume;
done


for volume_type in $volume_types; do 
    openstack volume type delete $volume_type;
done


flavors=$(openstack flavor list | grep tempest | awk '{print $2}')

for flavor in $flavors; do
    openstack flavor delete $flavor;
done
