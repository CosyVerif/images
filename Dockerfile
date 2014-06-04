FROM saucisson/debian-32:stable
MAINTAINER alban.linard@lsv.ens-cachan.fr

# Set i386 and amd64 architectures:
#RUN dpkg --add-architecture i386
#RUN dpkg --add-architecture amd64

# Update Debian package list:
RUN apt-get update -y

# Set to non interactive mode, and install missing package:
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y apt-utils

# Update the system:
RUN apt-get dist-upgrade -y

# Install required 64 bits libraries to run Docker.io with a 32 bits image:
# RUN apt-get install -y libc6:amd64

# Configure APT to avoid installing recommended or suggested dependencies.
# Also try to save as much disk space as possible.
ADD ./data/etc/apt/apt.conf.d/02reduce /etc/apt/apt.conf.d/02reduce

# Avoid installing some documentation files with dpkg:
RUN apt-get install -y locales
ADD ./data/etc/dpkg/dpkg.cfg.d/01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
ADD ./data/etc/locale.gen /etc/locale.gen
RUN apt-get --reinstall install -y $(dpkg --get-selections | grep install | grep -v deinstall | cut -f1)

# Install fstab:
ADD ./data/etc/fstab /etc/fstab

# Install custom kernel:
RUN apt-get install -y linux-source fakeroot kernel-package
RUN mkdir /tmp/kernel
RUN tar -xf /usr/src/linux-source*.tar.* -C /tmp/kernel --strip-components=1
ADD ./data/kernel.config /tmp/kernel/.config
RUN cd /tmp/kernel && yes "" | make oldconfig
RUN cd /tmp/kernel && fakeroot make-kpkg --append-to-version -vbox --initrd kernel-image
RUN cd /tmp/ && dpkg -i linux-image-*.deb
RUN apt-get purge -y linux-source fakeroot kernel-package

# Install cosyverif user:k
RUN useradd -G users -d /home/cosyverif -s /bin/bash cosyverif
# RUN echo cosyverif | passwd cosyverif --stdin
RUN mkdir -p /home/cosyverif/.m2/
ADD ./data/maven-settings.xml /home/cosyverif/.m2/settings.xml
RUN chown -R cosyverif.users /home/cosyverif/

# Clean:
RUN rm -rf /tmp/*
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -f /var/lib/apt/lists/*
RUN rm -f /var/cache/debconf/*
RUN 

# Set cosyverif user:
USER cosyverif
