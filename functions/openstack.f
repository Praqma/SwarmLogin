#! /bin/bash

# This function extract a property from a STACI property file
#
# 1: name of OpenStack instance
# 2: flavor size of instance
# 3: swarm id from docker run swarm create
# 4: 0 or 1. If 1, then the instance will become a swarm master
#
function createOpenStackInstance(){
    local instance_name=$1
    local flavor=$2
    local swarmid=$3
    local swarm_master=$4

    if [ $swarm_master = 1 ]; then
        setMaster="--swarm-master"
    fi
    docker-machine create \
        --driver openstack \
        --openstack-net-id be63ef5c-0656-42e5-9f80-8754ff9fcb23 \
        --openstack-flavor-id $flavor \
        --openstack-image-id e12ff7e3-9638-4b27-b050-616880d832af  \
        --openstack-ssh-user ubuntu  \
        --openstack-sec-groups default,DockerAPI  \
        --swarm \
        $setMaster  --swarm-discovery=token://$swarmid \
        $instance_name  
}

