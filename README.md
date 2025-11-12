# 20251205 Martinos Scanner Demo

The goal is of this demo is to show how to perfrom structural MR analysis and visualization on Seimens MRI hardware without any configuration changes to the reconstruction computer (mars)

This demo inludes:
- How to send DICOMs to the reconstruction computer (mars)
- How to automaiticaly initialize a [freesurfer](https://github.com/freesurfer/freesurfer) reconstruction on mars
- How to view the results in a browser on the host computer using [freebrowse](https://github.com/freesurfer/freebrowse)

## Pre-requisites

- A modern web browser must be installed on the host computer.  We have installed ??? on the host.
- The following docker containers
  - `pwighton/freebrowse:20251110`
  - `pwighton/areg:20251112-min-temp`
  - See [doc/building-containers.md](doc/building-containers.md) for instructions on how to build the containers
- The password for the samba user `mars` on the mars computer

## Setup

On a laptop, export the containers:

```
cd /home/paul/lcn/git/scanner-demo-20251205
docker save pwighton/freebrowse:20251110 | gzip > containers/pwighton-freebrowse-20251110.tar.gz
docker save pwighton/areg:20251112-min | gzip > containers/pwighton-areg-20251112-min.tar.gz
```

### Host

- Install a modern browser
- Configure the BOLD dot-addin to send dicoms to mars:
  - Target Host: `\\192.168.2.2`
  - Target Directory: `\service`
  - Username: `siemens\mars`
  - Password: Enter the password for the samba user `mars` on the mars computer here
  - When a sequence with the addin is run, this will place dicoms in a subfolder of `/service` on mars

### Mars

Connect laptop to internal network switch, then
```
sudo ifconfig enp132s0 192.168.2.5
ping 192.168.2.1
ping 192.168.2.2
ssh -t root@192.168.2.2 \
  "mkdir -p /tmp/demo/containers; \
   mkdir -p /tmp/demo/scripts; \
   mkdir -p /tmp/demo/nvd-templates; \
   mkdir -p /tmp/demo/areg-filters; \
   mkdir -p /tmp/demo/areg-work-dir; \
   mkdir -p /tmp/demo/freebrowse-data-dir"
cd /home/paul/lcn/git/scanner-demo-20251205
scp containers/*.tar.gz root@192.168.2.2:/tmp/demo/containers
scp scripts/* root@192.168.2.2:/tmp/demo/scripts
scp nvd-templates/* root@192.168.2.2:/tmp/demo/nvd-templates
scp areg-filters/* root@192.168.2.2:/tmp/demo/areg-filters
```
replace `enp132s0` with the name of your network card

Then establish an interactive ssh connection to mars:
```
ssh root@192.168.2.2
```

On mars:
```
docker load -i /tmp/demo/containers/pwighton-areg-20251112-min.tar.gz
docker load -i /tmp/demo/containers/pwighton-freebrowse-20251110.tar.gz
```

## Run

On mars, start autoregister:
```
docker run -it --rm \
  -v /tmp/demo:/tmp/demo \
  -v /service:/bold-dicom \
  pwighton/areg:20251112-min \
    auto_register.py \
      -s /tmp/demo/areg-work-dir \
      --input-mode directory \
      --watch-directory /bold-dicom \
      --disable-default-areg \
      --command /tmp/demo/scripts/recon.bash
```

On mars, also start FreeBrowse:
```
docker run \
  --rm \
  -p 5173:5173 \
  -p 9999:9999 \
  -v /tmp/demo/freebrowse-data-dir:/app/data   \
    pwighton/freebrowse:20251110 \
      server \
      --frontend-port 5173 \
      --backend-port 9999
```

On the host, browse to http://192.168.2.2.:5173/
