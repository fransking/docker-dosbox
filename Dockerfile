FROM balenalib/raspberry-pi-debian:build as build

RUN echo "deb-src http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends \
        git \
        pulseaudio \
        libpulse-dev \
        autoconf \
        m4 \
        intltool \
        build-essential \
        ssl-cert \
        dpkg-dev \
        libepoxy-dev \
        libgbm-dev

RUN mkdir /build && \
    cd /build && \
    apt-get build-dep xrdp && \
    git clone https://salsa.debian.org/debian-remote-team/xrdp.git && \
    cd xrdp && \
    dpkg-buildpackage -rfakeroot -uc -b && \
    cd /build && \
    dpkg -i xrdp*.deb

RUN cd /build && \
    apt-get build-dep xorgxrdp && \
    git clone https://salsa.debian.org/debian-remote-team/xorgxrdp.git

RUN cd /build/xorgxrdp && \
    #patch xorgxrdp according to https://github.com/neutrinolabs/xrdp/issues/1503
    sed -i 's/GLAMOR_USE_EGL_SCREEN | GLAMOR_NO_DRI3/GLAMOR_USE_EGL_SCREEN/g' xrdpdev/xrdpdev.c && \ 
    #end
    dpkg-buildpackage -rfakeroot -uc -b && \
    cd /build && \
    dpkg -i xorgxrdp*.deb

RUN cd /build && \
    apt-get build-dep pulseaudio -y && \
    apt-get source pulseaudio && \
    pulserver=$(pulseaudio --version | awk '{print $2}') && \
    cd pulseaudio-$pulserver && \
    ./configure && \
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
    cd pulseaudio-module-xrdp && \
    ./bootstrap && \
    ./configure PULSE_DIR="/build/pulseaudio-$pulserver" && \
    make && \
    cd src/.libs && \
    install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so



FROM balenalib/raspberry-pi-debian:run

ENV LANG=en_GB.UTF-8
ENV LANGUAGE=${LANG}
ENV LC_ALL=${LANG}
ENV TZ=Europe/London

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends locales && \
    echo "${LANG} UTF-8" >> /etc/locale.gen && \
    touch /usr/share/locale/locale.alias && \
    dpkg-reconfigure locales

RUN apt-get install -y --no-install-recommends \
      ssl-cert \
      fuse \
      xorg \
      xserver-xorg \
      xserver-xorg-legacy \
      xinit \
      xfonts-100dpi \
      xfonts-75dpi \
      xfonts-scalable \ 
      openbox \
      xterm \
      s6 \
      dbus-x11 \
      wget \
      pulseaudio \
      libasound2-plugins \
      volumeicon-alsa \
      alsa-base \
      alsa-utils \
      mesa-utils \
      x11vnc \
      xinit \
      lxterminal \
      kbd \
      neverball && \
    apt-get upgrade && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* 

COPY --from=build /var/lib/xrdp-pulseaudio-installer /var/lib/xrdp-pulseaudio-installer
COPY --from=build /build/*.deb /tmp/

RUN dpkg -i /tmp/*.deb && \
    rm -rf /tmp/*.deb

RUN useradd -m dosbox && \
    echo "exec openbox-session" >> /home/dosbox/.xinitrc && \
    chown dosbox:dosbox /home/dosbox/.xinitrc && \
    mkdir -p /home/dosbox/.config/openbox && \
    chown -R dosbox:dosbox /home/dosbox/.config && \
    echo "(sleep 1s && pulseaudio --start && sleep 2s && volumeicon) &" >> /home/dosbox/.config/openbox/autostart.sh && \
    chmod +x /home/dosbox/.config/openbox/autostart.sh && \
    echo dosbox:dosbox | chpasswd && \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config && \
    mkdir /var/run/dbus

COPY etc/ /etc/

EXPOSE 3389 5900
CMD ["s6-svscan", "/etc/s6"]
