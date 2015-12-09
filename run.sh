
source functions/openstack.f

echo "Please enter your OpenStack username: "
read -sr OS_USERNAME_INPUT

echo "Please enter your OpenStack Password: "
read -sr OS_PASSWORD_INPUT

export OS_AUTH_URL=https://identity.api.zetta.io/v3
export OS_REGION_NAME=no-osl1
export OS_PROJECT_ID=bceffc437a324a64ac708205dcad8208
export OS_PROJECT_NAME=Standard
export OS_PROJECT_DOMAIN_ID=807427196c02496ea86bc65a110472e6
export OS_USER_DOMAIN_ID=807427196c02496ea86bc65a110472e6
export OS_IDENTITY_API_VERSION=3
export OS_USERNAME=$OS_USERNAME_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
export OS_TENANT_NAME=standard
export OS_DOMAIN_NAME=praqma

swarmid=$(docker run swarm create)
createOpenStackInstance testswarm-m 6 $swarmid 1 &
createOpenStackInstance testswarm-01 6 $swarmid 0 &
createOpenStackInstance testswarm-01 6 $swarmid 1 &

wait

eval $(docker-machine env --swarm testswarm-m)

# Build our Apache PHP container
(cd images/web/context
docker build -t swarmlogin/php:latest .)

# Build our MySql database container
(cd images/mysql/context
docker build -t swarmlogin/mysql:latest .)

# Start docker-compose
(cd compose
docker-compose up)
