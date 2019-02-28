FROM jakirkham/centos
MAINTAINER John Kirkham <jakirkham@gmail.com>

# Add a timestamp for the build. Also, bust the cache.
ADD http://worldclockapi.com/api/json/utc/now /opt/docker/etc/timestamp

ENV LANG en_US.UTF-8

RUN echo "exclude=*.i386 *.i686" >> /etc/yum.conf && \
    yum update -y -q && \
    yum clean all -y -q

ADD miniconda /usr/share/miniconda
RUN /usr/share/miniconda/install_miniconda.sh

ADD docker /usr/share/docker

ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/usr/share/docker/entrypoint.sh" ]
CMD [ "/bin/bash" ]
