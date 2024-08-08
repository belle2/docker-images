#!/bin/bash

ARGS=$*
echo "${ARGS}"

while IFS=, read -r SYSTEM IMAGE DESCRIPTION PREPARE CLEANUP; do
  if [ -n "${ARGS}" ]; then
    if [[ "${ARGS}" != *"${SYSTEM}"* ]]; then
      continue
    fi
  fi

  DOCKERDIR=DockerDir_${SYSTEM}
  mkdir -p ${DOCKERDIR}

  TAG="latest"
  if [ -n "${CI_COMMIT_TAG}" ]; then
    TAG="${CI_COMMIT_TAG}"
  fi

  ./create_docker_files.sh ${SYSTEM}
  
  docker build -t "belle2-base-${SYSTEM}:${TAG}" ${DOCKERDIR}
  docker run --rm -v ./tests:/mnt "belle2-base-${SYSTEM}:${TAG}" /mnt/test.sh

  rm -rf ${DOCKERDIR}
  
done < systems.csv
