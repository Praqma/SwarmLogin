
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


# Build our Apache PHP container
(cd images/web/context
docker build -t hoeghh/php:latest .
docker push hoeghh/php:latest
)

# Create an Instance for MySQL to run on
echo " - Creating MySQL instance"
createOpenStackSwarmInstance test-sql 6  > ./logs/openstack-sql 2>&1
wait 5
mysqlIP=$(docker-machine ip tests-sql)

# Point docker client at testswarm-sql
eval $(docker-machine env test-sql)

# Build our MySql database container
(cd images/mysql/context
docker build -t hoeghh/mysql:latest .)

# Run MySQL on OpenStack instance
docker run -d -p 3306:3306 -h mysql -e MYSQL_ROOT_PASSWORD=password hoeghh/mysql:latest

swarmid=$(docker run swarm create)
echo "Swarm ID : $swarmid" > ./logs/swarmid.txt

echo " - Creating Swarm master instance"
createOpenStackSwarmInstance testswarm-00 6 "$swarmid" 1  > ./logs/openstack-00 2>&1 

echo " - Creating Swarm slave instance 01"
createOpenStackSwarmInstance testswarm-01 6 "$swarmid" 0  > ./logs/openstack-01 2>&1 


# Point docker client at swarm master
eval $(docker-machine env --swarm testswarm-00)


# Start docker-compose
(cd compose
cat << EOF > docker-compose.yml
php:
  image: hoeghh/php
  expose:
    - "80"
  ports:
    - "80:80"
  environment:
    - git_repo=https://github.com/Praqma/web-deployment-poc-code.git
    - mysql_ip=$mysqlIP
EOF
docker-compose up -d
docker-compose scale php=2)
