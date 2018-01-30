#!/bin/bash

set -e

# Update yum.
yum update -y -q

# Install curl to download the miniconda setup script.
yum install -y -q curl

# Install bzip2.
yum install -y -q bzip2 tar

# Install dependencies of conda's Qt4.
yum install -y -q libSM libXext libXrender

# Install basic fonts (needed by things like Graphviz).
yum install -y -q urw-fonts

# Clean out yum.
yum clean all -y -q

export MINICONDA_VERSION="4.3.21"
export MINICONDA2_CHECKSUM="7097150146dd3b83c805223663ebffcc"
export MINICONDA3_CHECKSUM="c1c15d3baba15bf50293ae963abef853"

# Install everything for both environments.
export OLD_PATH="${PATH}"
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
    bash "miniconda${PYTHON_VERSION}.sh" -b -p "${INSTALL_CONDA_PATH}"
    rm "miniconda${PYTHON_VERSION}.sh"
    rm -rf ~/.pki

    # Configure `conda` and add to the path
    export PATH="${INSTALL_CONDA_PATH}/bin:${OLD_PATH}"
    source activate root
    conda config --system --set show_channel_urls True

    # Add conda-forge to our channels.
    conda config --system --add channels conda-forge

    # Provide an empty pinning file should it be needed.
    touch "${INSTALL_CONDA_PATH}/conda-meta/pinned"

    # Update conda and other basic dependencies.
    conda update -qy --all

    # Update to latest Python minor version.
    conda install -qy "python=${PYTHON_VERSION}"

    # Install some other conda relevant packages.
    conda update -qy --all
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

    # Provide links in standard path.
    ln -s "${INSTALL_CONDA_PATH}/bin/python"  "/usr/local/bin/python${PYTHON_VERSION}"
    ln -s "${INSTALL_CONDA_PATH}/bin/pip"  "/usr/local/bin/pip${PYTHON_VERSION}"
    ln -s "${INSTALL_CONDA_PATH}/bin/conda"  "/usr/local/bin/conda${PYTHON_VERSION}"
done

# Set the conda3 environment as the default.
# This should be removed in the future.
ln -s /opt/conda3 /opt/conda
