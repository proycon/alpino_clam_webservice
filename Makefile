docker:
	docker build -t proycon/alpino_webservice:latest .

docker-dev:
	docker build -t proycon/alpino_webservice:dev --build-arg VERSION=development .

