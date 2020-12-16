FROM ubuntu:20.04

ARG UID=9001
ARG GID=9001
ARG UNAME=ubuntu
ARG HOSTNAME=docker
ARG NEW_HOSTNAME=${HOSTNAME}-Docker
ARG USERNAME=$UNAME
ARG HOME=/home/$USERNAME


RUN useradd -u $UID -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid $UID $USERNAME && \
        groupmod --gid $GID $USERNAME && \
        chown -R $USERNAME:$USERNAME $HOME && \
        chmod 666 /dev/null && \
        chmod 666 /dev/urandom && \
        rm /etc/apt/apt.conf.d/docker-gzip-indexes


RUN echo 'path-include=/usr/share/locale/ja/LC_MESSAGES/*.mo' > /etc/dpkg/dpkg.cfg.d/includes \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        sudo \
        lxde \
        xrdp \
        ibus \
        ibus-mozc \
        language-pack-ja-base \
        language-pack-ja \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        supervisor \
        gosu \
        build-essential \
        curl \
        less \
        apt-utils \
        tzdata \
        git \
        tmux \
        bash-completion \
        command-not-found \
        libglib2.0-0 \
        gstreamer1.0-plugins-* \
        libgstreamer1.0-* \
        libgstreamer-plugins-*1.0-* \
        vim \
        emacs \
        ssh \
        rsync \
        python3-pip \
        sed \
        ca-certificates \
        wget \
        lsb-release \
        gnupg \
        gnupg2 \
        htop
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y \
        ros-noetic-desktop-full \
        python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool

RUN rosdep init

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN apt-get update && apt-get install -y \
        ros-foxy-desktop

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $USERNAME
RUN mkdir -p ~/.config/autostart/
RUN { \
      echo '[Desktop Entry]'; \
      echo 'Type=Application'; \
      echo 'Name=SetJPKeyboard'; \
      echo 'Exec=setxkbmap -layout jp'; \
      echo 'OnlyShowIn=LXDE'; \
    } > ~/.config/autostart/setxkbmap.desktop

RUN rosdep update

RUN pip3 install -U argcomplete

USER root

# Set locale
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' > /etc/timezone
RUN locale-gen ja_JP.UTF-8 \
    && echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale \
    && echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale
ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# RUN mkdir -p /etc/X11/xorg.conf.d/
# RUN { \
#       echo 'Section "InputClass"'; \
#       echo '        Identifier "system-keyboard"'; \
#       echo '        MatchIsKeyboard "on"'; \
#       echo '        Option "XkbLayout" "jp,us"'; \
#       echo '        Option "XkbModel" "jp106"'; \
#       echo '        Option "XkbOptions" "grp:alt_shift_toggle"'; \
#       echo 'EndSection'; \
#     } > /etc/X11/xorg.conf.d/00-keyboard.conf

# RUN echo '# KEYBOARD CONFIGURATION FILE' > /etc/default/keyboard
# RUN echo '# Consult the keyboard(5) manual page.' >> /etc/default/keyboard
# RUN echo 'XKBMODEL="pc109"' >> /etc/default/keyboard
# RUN echo 'XKBLAYOUT="jp"' >> /etc/default/keyboard
# RUN echo 'XKBVARIANT=""' >> /etc/default/keyboard
# RUN echo 'XKBOPTIONS=""' >> /etc/default/keyboard
# RUN echo 'BACKSPACE="guess"' >> /etc/default/keyboard


# Expose RDP port
EXPOSE 3389

RUN echo "startlxde" > /etc/skel/.xsession \
    && install -o root -g xrdp -m 2775 -d /var/run/xrdp \
    && install -o root -g xrdp -m 3777 -d /var/run/xrdp/sockdir \
    && install -o root -g root -m 0755 -d /var/run/dbus

# Set supervisord conf for xrdp service
RUN { \
      echo "[supervisord]"; \
      echo "user=root"; \
      echo "nodaemon=true"; \
      echo "logfile=/var/log/supervisor/supervisord.log"; \
      echo "childlogdir=/var/log/supervisor"; \
      echo "[program:dbus]"; \
      echo "command=/usr/bin/dbus-daemon --system --nofork --nopidfile"; \
      echo "[program:xrdp-sesman]"; \
      echo "command=/usr/sbin/xrdp-sesman --nodaemon"; \
      echo "[program:xrdp]"; \
      echo "command=/usr/sbin/xrdp --nodaemon"; \
      echo "user=xrdp"; \
    } > /etc/supervisor/xrdp.conf

USER $USERNAME
RUN rm -rf ~/.cache
USER root

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]