docker:
	docker build --no-cache -t proycon/alpino_webservice:latest .

docker-dev:
	docker build --no-cache -t proycon/alpino_webservice:dev --build-arg VERSION=development .

