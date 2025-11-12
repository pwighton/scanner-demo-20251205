# Buildling containers

This demo requires 2 containers:
- One to run [freebrowse](https://github.com/freesurfer/freebrowse)
- One to run [freesurfer](https://github.com/freesurfer/freesurfer) and [auto-register](https://github.com/pwighton/auto-register/)

See the [FreeBrowse docker readme](https://github.com/freesurfer/freebrowse/blob/main/docker/README.md) for instructions on how to build this cotnainer.  We will call this container `pwighton/freebrowse:20251110`.

See the [Autoregister docker readme](https://github.com/pwighton/auto-register/blob/20251110-arb-cmd/docker/README.md) (which is currently on the branch called `20251110-arb-cmd`) for instructions how to build container with both FreeSurfer 8.1.0 and Auto-register.  We will call this container `pwighton/areg:20251112`.

## Minify `pwighton/areg:20251112`

The `pwighton/areg:20251112` container is 20.8GB, which is too big to run on mars without changing the default docker container location.  We will therefore minify this container using [`neurodocker minify`](https://repronim.org/neurodocker/user_guide/minify.html)

We will use `neurodocker minify` to create a minified container called `pwighton/areg:20251112-min-temp`.  This container will have all the files needed to run the demo, but `neurodocker minify` will remove key environment variables.  Therefore, we will use the `Dockerfile` in this repo, to add back in the required environment variables.

### Install neurodocker

We can't `pip install neurodocker` (as of 20251112) because the packaged version uses Mambaforge instead of Miniforge3, which is deprecated and the link it used to download Mambaforge no longer works.  We will therefor installing from source.

```
conda create -n neurodocker python=3.12
conda activate neurodocker
git clone git@github.com:ReproNim/neurodocker.git
cd neurodocker
pip install -e ".[all]"
```

### Setup the environment for minifying

Run `setup-areg-laptop.sh` from the top-level directory of this repo:
```
./setup-areg-laptop.sh
```

Run the container we want to minimize.
```
./run-areg-laptop.sh pwighton/areg:20251112
```

Then, in another terminal, copy the test dicom to the auto-register watch directory:
```
cp ./dcm/pickels.dcm /tmp/bold-dicom
```

When auto-register has finished processes this dicom (~30 seconds), you should see something like:
```
SYNTHSEG DONE; TOOK 29 SECONDS

Running: rm -rf '/tmp/dcm2niix_dg2TDV'
```

You can now hit 'q' to stop auto-register.  We now have:
- a dicom at `/tmp/bold-dicom/pickels.dcm`
- a corresponding nifti at `/tmp/demo/areg-work-dir/img-00000.nii.gz`

And are ready to minify the container.

### Minify

Start the container in one terminal
```
docker run --rm -it \
  --security-opt seccomp:unconfined \
  --network host \
  --name container-to-min \
  -v /tmp/demo:/tmp/demo \
  -v /tmp/bold-dicom:/bold-dicom \
  --entrypoint /bin/bash \
    pwighton/areg:20251112
```

Then, in another terminal, define the minification commands:
```
cmd1="/tmp/demo/scripts/recon.bash /bold-dicom/pickels.dcm /tmp/demo/areg-work-dir/img-00000.nii.gz"
cmd2="echo hello"
```

Run `neurodocker minify`:
```
neurodocker minify \
  --yes \
  --container container-to-min \
  --dir /usr/local/freesurfer \
  "$cmd1" "$cmd2" \
&& docker export container-to-min \
| docker import - pwighton/areg:20251112-min-temp
```

This creates a container called `pwighton/areg:20251112-min-temp`, which is 2.19GB.  The original container, `pwighton/areg:20251112` was 20.8GB.

### Reset Environment Variables

The minification process disturbed the container's environment variables.  Compare:
- `docker run -it --rm pwighton/areg:20251112 env`
- `docker run -it --rm pwighton/areg:20251112-min-temp env`

So lets create a container, called `pwighton/areg:20251112-min` which inherits from `pwighton/areg:20251112-min-temp env` and puts back the required environment variables.  The `Dockerfile` in this repo will do this.

Run
```
docker build -t pwighton/areg:20251112-min .
```

### Verify Minified Containers

Run `setup-areg-laptop.sh` from the top-level directory of this repo:
```
./setup-areg-laptop.sh
```

Run the minified container.
```
./run-areg-laptop.sh pwighton/areg:20251112-min
```

Then, in another terminal, copy the test dicom to the auto-register watch directory:
```
cp ./dcm/pickels.dcm /tmp/bold-dicom
```

When auto-register has finished processes this dicom (~30 seconds), you should see something like:
```
SYNTHSEG DONE; TOOK 29 SECONDS

Running: rm -rf '/tmp/dcm2niix_dg2TDV'
```

