CLUSTER_NAME=mycluster
IMAGE_NAME=custom-nginx
IMAGE_TAG=v1

.PHONY: setup cluster build import deploy verify expose all clean

setup:
	chmod +x setup.sh
	./setup.sh

cluster:
	k3d cluster create $(CLUSTER_NAME) -p "30080:30080@loadbalancer" || true

build:
	cd packer && packer init . && packer build .

import:
	k3d image import $(IMAGE_NAME):$(IMAGE_TAG) -c $(CLUSTER_NAME)

deploy:
	cd ansible && ansible-playbook -i inventory.ini deploy.yml

verify:
	kubectl get pods
	kubectl get svc
	kubectl get deployment

expose:
	kubectl port-forward svc/nginx-custom-service 8081:80

all: cluster build import deploy verify

clean:
	k3d cluster delete $(CLUSTER_NAME) || true
