DIRS?= -L ./Case_studies/ -L ./math_libs/ -L ./Qbricks/

build: Dockerfile
	docker build --tag image_qbricks .

container:
	bash container.sh

start:
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' container_qbricks` >> /dev/null
	docker start --attach --interactive container_qbricks

clean:
	docker container rm container_qbricks