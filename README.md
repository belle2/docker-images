# Belle II Docker images

This repository contains the scripts for automatically creating via pipeline the Docker images for building and running the Belle II software.

The pipeline creates one image for each of the supported OS (see `systems.csv` for the list of supported OS). The pipeline is automatically triggered via Git tag each time the file [b2install-prepare](https://github.com/belle2/tools/blob/main/b2install-prepare) is updated in the `main` branch of the `tools` repository.

The images are created using [kaniko](https://docs.gitlab.com/ee/ci/docker/using_kaniko.html). It is also possible to create the images locally with Docker by using the script `create_images.sh`.

The images are pushed to both the [GitLab container registry](https://gitlab.desy.de/belle2/software/docker-images/container_registry) and [Docker Hub](https://hub.docker.com/orgs/belle2/repositories).

### Naming convention

The images are named using the following convention:

    belle2-base-<os>:<YYYY-MM-DD>
    
where `<os>` is the short name of the supported OS and `<YYYY-MM-DD>` is the date on which the image has been created.

Note that the `latest` tag is also provided, which automatically points to the most recent image available for the given OS.

For pulling and/or using the images, please refer to the documentation of the container registry of Docker Hub.