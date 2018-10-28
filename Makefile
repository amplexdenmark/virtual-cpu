NAME="virtual-cpu"
IMAGE="virtual-cpu"

all: container

container: .docker
.docker: Dockerfile $(wildcard assets/**/* assets/*)
	docker build -t $(IMAGE) . && touch .docker

clean2:
	@echo "Removing old containers .."
	docker ps -aq --filter name=$(NAME) | ( x=`cat`; [ -z $x ] || docker rm -v $x )

clean: clean2
	rm .docker

shell: clean2 container
	@echo "Starting $(NAME) .."
	docker run --security-opt seccomp:unconfined \
		--name $(NAME) --hostname $(NAME) --rm --volume `pwd`/storage:/amplex \
		--env TERM=$(subst -italic,,$(TERM)) -it $(IMAGE) shell

bash: clean2 container
	@echo "Starting $(NAME) .."
	docker run --name $(NAME) --hostname $(NAME) --rm --volume `pwd`/storage:/amplex \
		--env TERM=$(subst -italic,,$(TERM)) -it --entrypoint=/bin/bash $(IMAGE) -i

start: clean2 container
	@echo "Running $(NAME) .."
	docker run --detach --name $(NAME) --hostname $(NAME) --rm --volume `pwd`/storage:/amplex \
		--publish 8042:8080/tcp $(IMAGE)

stop:
	docker ps -q --filter name=$(NAME) | ( x=`cat`; [ -z $x ] || docker stop $x )

logs:
	docker ps -q --filter name=$(NAME) | ( x=`cat`; [ -z $x ] || docker logs $x )

tail:
	docker ps -q --filter name=$(NAME) | ( x=`cat`; [ -z $x ] || docker logs --follow $x )

.PHONY: container clean clean2 shell bash run stop logs tail
