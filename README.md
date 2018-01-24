[![CircleCI](https://circleci.com/gh/jakirkham/docker_centos_conda/tree/master.svg?style=shield)](https://circleci.com/gh/jakirkham/docker_centos_conda/tree/master)
[![](https://badge.imagelayers.io/jakirkham/centos_conda:latest.svg)](https://imagelayers.io/?images=jakirkham/centos_conda:latest 'Get your own badge on imagelayers.io')
[![](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.txt 'Apache License Version 2.0')

# Purpose

In order to provide a simple portable conda-based environment. This repo contains what is necessary to build a CentOS 6 based image using Docker. In addition, it provides a copy of [`anaconda-client`]( http://docs.anaconda.org/ ) and [`conda`]( http://conda.pydata.org/ ) with some extensions for building.

# Building

## Automatic

This repo is part of an automated build, which is hosted on Docker Hub ( <https://hub.docker.com/r/jakirkham/centos_conda> ). Changes added to this trigger an automatic rebuild and deploy the resulting image to Docker Hub. To download an existing image, one simply needs to run `docker pull jakirkham/centos_conda`.

## Manual

If one wishes to develop this repo, building will need to be performed manually. This container can be built simply by `cd`ing into the repo and using `docker build --rm -t <NAME> .` where `<NAME>` is the name tagged to the image built. More information about building can be found in Docker's documentation ( <https://docs.docker.com/reference/builder> ). Please consider opening a pull request for changes that you make.

# Testing

A CircleCI build of the image is performed on each commit. `conda` is exercised to update the `root` environments to match those in [conda-forge]( https://conda-forge.org/ ).

# Usage

Once an image is acquired either from one of the provided builds or manually, the image is designed to provide a preconfigured shell environment. Simply run `docker run --rm -it <NAME>`. This starts up `bash` with a copy of `conda` in Python 2 and Python 3 environments available. In the case of an automated build, `<NAME>` is `jakirkham/centos_conda`.
