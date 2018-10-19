install:
	docker-compose exec engine-mao bash -c 'composer install'
	docker-compose exec engine-mao bash -c 'chmod -R 777 app/cache app/logs'
	docker-compose exec engine-mao bash -c 'cd bin && ln -s ../app/console ./'

schema:
	docker-compose exec engine-mao bash -c 'bin/console doctrine:schema:update --dump-sql -f'
