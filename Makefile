IMAGE := localhost/rootless-libvirt:latest

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
WORK_DIR := $(dir $(MAKEFILE_PATH))

.PHONY: all build test-kvm test-no-kvm
all: build test-no-kvm test-kvm

build:
	podman build -t ${IMAGE} .

tests/original-debian-13.qcow2:
	curl -o $@ -L https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2

test-kvm: tests/original-debian-13.qcow2
	podman \
		run \
		--rm \
		--name libvirtd-test-kvm \
		--privileged \
		--userns=keep-id:uid=1000,gid=1000 \
		--group-add=keep-groups \
		--device /dev/kvm \
		--volume ${WORK_DIR}/tests:/src:O \
		--workdir /src \
		--env ANSIBLE_FORCE_COLOR=1 \
		${IMAGE} \
		bash -c "sudo apt-get update && sudo apt-get install --no-install-recommends --assume-yes ansible python3-lxml && ansible-playbook playbook.yml"

test-no-kvm: tests/original-debian-13.qcow2
	podman \
		run \
		--rm \
		--name libvirtd-test-kvm \
		--privileged \
		--userns=keep-id:uid=1000,gid=1000 \
		--volume ${WORK_DIR}/tests:/src:O \
		--workdir /src \
		--env ANSIBLE_FORCE_COLOR=1 \
		${IMAGE} \
		bash -c "sudo apt-get update && sudo apt-get install --no-install-recommends --assume-yes ansible python3-lxml && ansible-playbook --extra-vars '{\"enable_kvm\": false}' playbook.yml"
