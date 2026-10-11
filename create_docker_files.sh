#!/bin/bash

# Read arguments
ARGS=$*

# For all requested systems, read setup information from systems.csv and create Dockerfile
while IFS=, read -r SYSTEM IMAGE DESCRIPTION PREPARE CLEANUP; do
  if [ -n "${ARGS}" ]; then
    if [[ "${ARGS}" != *"${SYSTEM}"* ]]; then
      continue
    fi
  fi

  # Create a folder for storing all the relevant files
  DOCKERDIR=DockerDir_${SYSTEM}
  mkdir -p ${DOCKERDIR}

  # Grab the commit tag if available
  TAG="latest"
  if [ -n "${CI_COMMIT_TAG}" ]; then
    TAG="${CI_COMMIT_TAG}"
  fi

  echo "Creating Dockerfile under ${DOCKERDIR} for ${SYSTEM}"

  # Put all the additional files into the folder
  wget https://raw.githubusercontent.com/belle2/tools/main/b2install-prepare
  chmod +x b2install-prepare
  mv b2install-prepare ${DOCKERDIR}/

  # Start creating the Dockerfile
  cat > ${DOCKERDIR}/Dockerfile << EOF
FROM ${IMAGE}
LABEL Maintainer="The Belle II Software Group <software@belle2.org>"
LABEL Description="${DESCRIPTION} image with Belle II dependencies installed. To be used with a cvmfs bind mound at /cvmfs"
LABEL Version="${TAG}"
SHELL ["/bin/bash", "-c"]
ENV BELLE2_NO_TOOLS_CHECK 1
ENV BELLE2_SYSTEM=${SYSTEM}
EOF

  # If we build CentOS 7, then we need few extra instructions to run because of EOL
  if [[ "${SYSTEM}" == "el7" ]]; then
    cp centos7/CentOS-Base.repo ${DOCKERDIR}
    cat >> ${DOCKERDIR}/Dockerfile << EOF
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bkp
ADD CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum clean all && yum makecache
EOF
  fi

  # Finish creating the Dockerfile
  cat >> ${DOCKERDIR}/Dockerfile << EOF
ADD b2install-prepare /b2install-prepare
RUN ${PREPARE} /b2install-prepare --non-interactive all ${CLEANUP} && rm /b2install-prepare
EOF

  # EL8 only ships OCaml 4.07, while whizard requires at least 4.11. Install a
  # recent release from the OCaml distribution into /usr/local, which comes
  # before /usr/bin in PATH and therefore shadows the system package.
  if [[ "${SYSTEM}" == "el8" ]]; then
    OCAML_VERSION=4.14.2
    cat >> ${DOCKERDIR}/Dockerfile << EOF
RUN mkdir /ocaml-build && cd /ocaml-build \\
    && wget -q https://github.com/ocaml/ocaml/archive/refs/tags/${OCAML_VERSION}.tar.gz \\
    && tar xzf ${OCAML_VERSION}.tar.gz && cd ocaml-${OCAML_VERSION} \\
    && ./configure --prefix=/usr/local --disable-ocamldoc --disable-debugger \\
    && make -j\$(nproc) && make install \\
    && cd / && rm -rf /ocaml-build /usr/local/lib/ocaml/compiler-libs
EOF
  fi

done < systems.csv
