#!/bin/bash


if [ -z "$1" ]; then
        echo "Usage bash $0 <path to source file>"
        exit 1
fi

source "$1"

# server cleanup

servers=$(openstack server list -c Name -c ID | grep tempest | awk '{print $2}')

for server in $servers; do 
    echo "attempt to delete server $server" 

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

    if openstack floating ip list | grep $port | awk '{print $2}'; then
        echo "attempt to delete fip of $port"
        openstack floating ip delete "$(openstack floating ip list | grep $port | awk '{print $2}')";
    fi

    for port in $ports; do
        echo "attempt to delete subnet $subnet"
        if openstack subnet delete $subnet; then
            echo "subnet $subnet has been deleted"
	else
            echo "subnet $subnet has not been deleted"
        fi
	    
	echo "attempt to delete $port"
	if openstack port delete $port; then
            echo "port $port has been deleted"
        else
            echo "port $port has not been deleted, attempt to delete common entities"

	    router=$(openstack port show $port | grep device_id | awk '{print $4}')

            ports_of_router=$(openstack router show $router | grep interfaces_info | grep -oE '\"port_id\":\s\"[0-9a-zA-Z\-]+\"' | grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")

            for port in $ports_of_router; do
     	        if openstack router remove port $router $port; then
                    echo "port $port has been removed from $router"
	        else
                    echo "port $port has not been removed from $router"
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
 
 	    echo "second attempt to delete subnet $subnet"
            if openstack subnet list | grep $subnet; then
                echo "second attempt to delete subnet $subnet"
		
		if openstack subnet delete $subnet; then
		    echo "subnet $subnet has been deleted"
	        else    
                    echo "subnet $subnet has been deleted"
                fi
	    fi
	fi
    done
done


# router cleanup

routers=$(openstack router list | grep tempest | awk {'print $2'})

for router in $routers; do
    if openstack router delete $router; then
        echo "router $router has been deleted"
    else
        echo "router $router has not been deleted"
    fi
done


# security group cleanup 

security_groups=$(openstack security group list | grep tempest | awk '{print $2}')

for sg in $security_groups; do
    if openstack security group delete $sg; then
	echo "security group $sg has been deleted"
    else
        echo "security group $sg has not been deleted"
    fi
done


# networks & subnetworks cleanup

subnets=$(openstack subnet list | grep tempest | awk '{print $2}')
networks=$(openstack network list | grep tempest | awk '{print $2}')


for subnet in $subnets; do
    if openstack subnet delete $subnet; then
	echo "subnet $subnet has been deleted"
    else
        echo "subnet $subnet has not been deleted"
    fi
done

for net in $networks; do
    if openstack network delete $net; then
	echo "network $net has been deleted"
    else
        echo "network $net has not been deleted"
    fi
done



# volume&flavor cleanup

volumes=$(openstack volume list | grep tempest | awk '{print $2}')
volume_types=$(openstack volume type list | grep tempest | awk '{print $2}')

for volume in $volumes; do
    if openstack volume delete $volume; then
	echo "volume $volume has been deleted"
    else
        echo "volume $volume has not been deleted"
    fi
done


for volume_type in $volume_types; do 
    if openstack volume type delete $volume_type; then
	echo "volume type $volume_type has been deleted"
    else
	echo "volume type $volume_type has not been deleted"
    fi
done


flavors=$(openstack flavor list | grep tempest | awk '{print $2}')

for flavor in $flavors; do
    if openstack flavor delete $flavor; then
        echo "flavor $flavor has been deleted"
    else
        echo "flavor $flavor has not been deleted"

    fi
done



# image cleanup

images=$(openstack image list -c ID -c Name | grep -ve ID -e Name | grep tempest | awk '{print $2}')

for image in $images; do
    if openstack image delete $image; then
        echo "image $image has been deleted"
    else
        echo "image $image has not been deleted"
    fi
done



# keypair cleanup

keypairs=$(openstack keypair list -c ID -c Name | grep -ve ID -e Name | grep tempest | awk '{print $2}')

for keypair in $keypairs; do
    if openstack keypair delete $image; then
        echo "keypair $keypair has been deleted"
    else
        echo "keypair $keypair has not been deleted"
    fi
done
