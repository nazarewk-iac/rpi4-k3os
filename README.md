# rpi4-k3os

This repository helps with quickly customizing base k3os image (supplied by https://github.com/sgielen/picl-k3os-image-generator ).

Why not using picl-k3os-image-generator? This is faster for changing configs.

## Quick start

1. copy and fill-in [`config/example.yaml`](config/example.yaml)

2. [optional] build the image:
    
    
    make build

3. put the image on your SD card ( /dev/mmcblk0 ), then bake:
    
    
    make bake
    
4. insert the card and boot your PI, wait for a few minutes until you can
     `ssh rancher@<hostname>` to it. See [sgielen/picl-k3os-image-generator](https://github.com/sgielen/picl-k3os-image-generator) for more info.
     
5. Copy-over KUBECONFIG:


    bin/get-kubeconfig "<hostname>" ~/.kube/config
