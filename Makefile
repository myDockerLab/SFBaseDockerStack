ACL = "sudo setfacl -dR -m u:$(whoami):rwX -m u:root:rwX var"



install:
	docker-compose exec engine-mao bash -c 'composer install'
	docker-compose exec engine-mao bash -c 'chmod -R 777 app/cache app/logs'

init: init-jwt install
	docker-compose exec engine-mao bash -c 'bin/console doctrine:database:drop --force'
	docker-compose exec engine-mao bash -c 'bin/console doctrine:database:create'
	docker exec -i percona-mao bash -c 'mysql -h $$HOSTNAME -u $$MYSQL_USER -p"$$MYSQL_PASSWORD" $$MYSQL_DATABASE' < app/Resources/sql/dump_api_2017-12-18.sql
	docker-compose exec engine-mao bash -c 'bin/console doctrine:migration:migrate --no-interaction'
	docker-compose exec engine-mao bash -c 'bin/grumphp git:init'
	
clean:
	rm -rf var/cache/dev
	docker-compose exec engine-mao bash -c 'bin/console cache:warmup'

init-jwt:
	mkdir -p var/jwt
	docker-compose exec engine-mao bash -c 'openssl genrsa -passout pass:ayruu -out var/jwt/private.pem -aes256 4096'
	docker-compose exec engine-mao bash -c 'openssl rsa -passin pass:ayruu -pubout -in var/jwt/private.pem -out var/jwt/public.pem'

update:
	docker-compose exec engine-mao bash -c 'composer update'

db-diff:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:migration:diff'

db-migrate:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:migration:migrate  --no-interaction'

db-rollback:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:migration:migrate  --no-interaction $(version)'

init-test:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:database:drop --force --env=test'
	docker-compose exec engine-mao bash -c 'bin/console doctrine:database:create --env=test'
	docker exec -i percona-mao bash -c 'mysql -h $$HOSTNAME -u $$MYSQL_USER -p"$$MYSQL_PASSWORD" ayruu_test' < app/Resources/sql/dump_api_2017-12-18.sql

init-acl:
	${ACL}

tests:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:migration:migrate --no-interaction --env=test'
	docker-compose exec engine-mao bash -c 'bin/console ca:wa --env=test'
	docker-compose exec engine-mao bash -c 'php -dzend_extension=xdebug.so bin/codecept run --coverage --coverage-xml --coverage-html'