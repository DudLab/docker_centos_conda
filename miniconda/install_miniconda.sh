#!/bin/bash

set -e

# Update yum.
yum update -y -q

# Install curl to download the miniconda setup script.
yum install -y -q curl

# Install bzip2.
yum install -y -q bzip2 tar

# Install dependencies of conda-forge's Qt.
yum install -y -q libSM libXext libXrender mesa-libGL

# Install basic fonts (needed by things like Graphviz).
yum install -y -q urw-fonts

# Clean out yum.
yum clean all -y -q

export MINICONDA_VERSION="4.4.10"
export MINICONDA2_CHECKSUM="dd54b344661560b861f86cc5ccff044b"
export MINICONDA3_CHECKSUM="bec6203dbb2f53011e974e9bf4d46e93"

# Prep directory structure for Miniconda installs.
mkdir /opt/conda2
mkdir /opt/conda3

# Set the conda3 environment as the default.
ln -s /opt/conda3 /opt/conda

# Share the pkg cache between installs.
mkdir /opt/conda/pkgs
ln -s /opt/conda/pkgs /opt/conda2/pkgs

# Install everything for both environments.
for PYTHON_VERSION in 2 3;
do
    export INSTALL_CONDA_PATH="/opt/conda${PYTHON_VERSION}"
    export MINICONDA_CHECKSUM="\${MINICONDA${PYTHON_VERSION}_CHECKSUM}"
    eval export MINICONDA_CHECKSUM=``${MINICONDA_CHECKSUM}``

    # Download and install `conda`.
    cd /usr/share/miniconda
    curl -L "https://repo.continuum.io/miniconda/Miniconda${PYTHON_VERSION}-${MINICONDA_VERSION}-Linux-x86_64.sh" > "miniconda${PYTHON_VERSION}.sh"
    openssl md5 "miniconda${PYTHON_VERSION}.sh"
    openssl md5 "miniconda${PYTHON_VERSION}.sh" | grep "${MINICONDA_CHECKSUM}"
    bash "miniconda${PYTHON_VERSION}.sh" -b -u -p "${INSTALL_CONDA_PATH}"
    rm -f "miniconda${PYTHON_VERSION}.sh"
    rm -rf ~/.pki

    # Configure `conda` and add to the path
    source "${INSTALL_CONDA_PATH}/etc/profile.d/conda.sh"
    conda activate base

    # Add conda-forge to our channels.
    conda config --system --set show_channel_urls True
    conda config --system --add channels conda-forge

    # Provide an empty pinning file should it be needed.
    touch "${INSTALL_CONDA_PATH}/conda-meta/pinned"

    # Update conda and other basic dependencies.
    conda update -qy conda

    # Update to latest Python minor version.
    # Ensure we use conda-forge's python no matter what.
    conda install -qy "conda-forge::python=${PYTHON_VERSION}"

    # Update everything else.
    conda update -qy --all

    # Install some other conda relevant packages.
    conda install -qy pycrypto
    conda install -qy conda-build
    conda install -qy anaconda-client
    conda install -qy jinja2

    # Install tini for the Docker container init process.
    conda install -qy tini

    # Pin tini to exactly the version installed.
    CONDA_TINI_INFO=( `conda list tini | grep tini` )
    echo "tini ${CONDA_TINI_INFO[1]}" >> "${INSTALL_CONDA_PATH}/conda-meta/pinned"

    # Install common VCS packages.
    conda install -qy git
    if [ "${PYTHON_VERSION}" == "2" ]
    then
        # Mercurial is Python 2 only.
        conda install -qy mercurial
    fi
    conda install -qy svn

    # Clean out all unneeded intermediates.
    conda clean -tipsy
    rm -rf ~/.conda

    # Provide shell wrapper scripts to run in each `conda` environment.
    for CONDA_ENV_CMD in "python" "pip" "conda"; do
        touch "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        chmod +x "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e '#!/bin/bash' >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "set -e" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "conda deactivate &> /dev/null || true" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "set -a" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e ". /opt/conda${PYTHON_VERSION}/etc/profile.d/conda.sh" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "conda activate base" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "set +a" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "" >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
        echo -e "exec ${CONDA_ENV_CMD} "'$@' >> "/usr/local/bin/${CONDA_ENV_CMD}${PYTHON_VERSION}"
    done

    # Remove `conda` from the path
    conda deactivate
done
