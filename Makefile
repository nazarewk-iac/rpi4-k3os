PACKER_VERSION ?= 1.5.5
PACKER_CONFIG ?= k3os-raspi.json
K3OS_IMAGE ?= picl-k3os-image-generator/picl-k3os-v0.10.0-raspberrypi.img

FAKE_CONFIG ?= picl-k3os-image-generator/config/aa:bb:cc:dd:ee:ff.yaml

TARGET_IMAGE ?= k3os-raspi.img

.ONESHELL:

build: $(K3OS_IMAGE) validate
	$(MAKE) umount || true
	sudo PACKER_LOG=1 bin/packer build "${PACKER_CONFIG}"
	sudo chown "$(id -u):$(id -g)" "$(TARGET_IMAGE)"


.PHONY: validate
validate: bin/packer bin/packer-builder-arm $(PACKER_CONFIG)
	bin/packer validate "${PACKER_CONFIG}"


.PHONY: bake
bake: $(TARGET_IMAGE)
	[[ -b /dev/mmcblk0 ]] || exit 1
	time sudo dd if=$(TARGET_IMAGE) of=/dev/mmcblk0 bs=4M status=progress

.PHONY: re-bake
re-bake: build bake

.PHONY: mount
mount: $(TARGET_IMAGE)
	bin/img mount $(TARGET_IMAGE) ./mnt-new

.PHONY: umount
umount:
	bin/img umount $(TARGET_IMAGE)


bin/packer:
	mkdir -p bin
	wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
	unzip packer_${PACKER_VERSION}_linux_amd64.zip
	rm packer_${PACKER_VERSION}_linux_amd64.zip
	mv packer bin/

bin/packer-builder-arm:
	set -x
	mkdir -p bin
	git clone https://github.com/mkaczanowski/packer-builder-arm
	pushd packer-builder-arm
		go mod download
		go build
	popd
	mv packer-builder-arm/packer-builder-arm bin/
	rm -rf packer-builder-arm

picl-k3os-image-generator/.gitignore:
	git submodule init
	git submodule update

$(K3OS_IMAGE): picl-k3os-image-generator/.gitignore
	touch "$(FAKE_CONFIG)"
	pushd picl-k3os-image-generator
	./build-image.sh raspberrypi

$(TARGET_IMAGE):
	$(MAKE) build

