# Belle II Docker images

This repository contains the scripts for automatically creating via pipeline the [Docker](https://www.docker.com/) images for building and running the Belle II software.

The pipeline creates one image for each of the supported OS (see `systems.csv` for the list of supported OS). The pipeline is automatically triggered by the buildbot via Git tag each time the file [b2install-prepare](https://github.com/belle2/tools/blob/main/b2install-prepare) is updated in the `main` branch of the `tools` repository.

The images are created using [kaniko](https://docs.gitlab.com/ee/ci/docker/using_kaniko.html). It is also possible to create the images locally with Docker by using the script `create_images.sh`.

The images are pushed to both the [GitLab container registry](https://gitlab.desy.de/belle2/software/docker-images/container_registry) and [Docker Hub](https://hub.docker.com/u/belle2). For using the images, please refer to the documentation of the GitLab container registry or Docker Hub.

Note that these images do NOT contain any of the Belle II software. They are intended to be used for bulding the Belle II software or for running it with a bind mount of the [CernVM-FS](https://cernvm.cern.ch/fs/) at `/cvmfs`.

### Naming convention

The images are named using the following convention:

    belle2-base-<OS>:<YYYY-MM-DD>
    
where `<OS>` is the short name of the supported OS (as in the first column of `systems.csv`) and `<YYYY-MM-DD>` is the date on which the image has been created.

Note that the `latest` tag is also provided, which automatically points to the most recent image available for the given OS. It is generally recommended to use the `latest` tag.

### Downloading the images

The images can be downloaded and stored locally using Docker itself, [skopeo](https://github.com/containers/skopeo) or [Apptainer](https://apptainer.org/) (only if a SIF file is necessary). For downloading the images from Docker Hub:

- with `docker` as a `tar` archive: `docker save -o belle2-base-<OS>-latest.tar belle2/belle2-base-<OS>:latest`
- with `skopeo` as a `tar` archive: `skopeo copy docker://belle2/belle2-base-<OS>:latest docker-archive:belle2-base-<OS>-latest.tar`
- with `apptainer` as a SIF file: `apptainer build belle2-base-<OS>-latest.sif docker://belle2/belle2-base-<OS>:latest`

See also the `download-and-inspect-images` stage of the pipeline.

### Running the Belle II software with Apptainer

The Belle II software can be run with Apptainer using the images created from this repository and mounting the `/cvfms` volume:

    apptainer exec --bind /cvmfs /path/to/belle2-base-<OS>-latest.sif /cvmfs/belle.cern.ch/tools/b2execute -x "basf2 --info" release-XX-YY-ZZ