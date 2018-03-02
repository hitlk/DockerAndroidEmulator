# Android development environment for ubuntu.
# version 0.0.5

FROM ubuntu

# Specially for SSH access and port redirection
ENV ROOTPASSWORD android

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Update packages
RUN apt-get -y update

RUN apt-get -y install software-properties-common bzip2 ssh net-tools openssh-server socat curl unzip

RUN add-apt-repository ppa:webupd8team/java

RUN apt-get update

RUN echo y | apt-get install oracle-java8-installer

RUN echo y | apt-get install mesa-utils

RUN echo y | apt-get install qemu-kvm

RUN echo y | apt-get install libvirt-bin

RUN echo y | apt-get install ubuntu-vm-builder

RUN echo y | apt-get install bridge-utils

RUN echo y | apt-get install qemu-system

RUN echo y | apt-get install kvm qemu

# Install android sdk
ARG SDK_VERSION=sdk-tools-linux-3859397
ARG ANDROID_BUILD_TOOLS_VERSION=26.0.0
ARG ANDROID_PLATFORM_VERSION="android-25"

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION

RUN wget -P ~/tmp https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip

RUN unzip ~/tmp/sdk-tools-linux-3859397.zip -d /usr/local/android-sdk

RUN chown -R root:root /usr/local/android-sdk/

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin

RUN mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;$ANDROID_PLATFORM_VERSION"

RUN $ANDROID_HOME/tools/bin/sdkmanager emulator --verbose

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

# Download android system images
RUN ./$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-25;google_apis;x86_64" --verbose

RUN ./$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-24;google_apis;x86_64" --verbose

RUN ./$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-23;google_apis;x86_64" --verbose

RUN ./$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-22;google_apis;x86_64" --verbose

RUN ./$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-21;google_apis;x86_64" --verbose

# Run sshd
RUN mkdir /var/run/sshd && \
    echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

ENV NOTVISIBLE "in users profile"

# replace libGL.so
ln -s -f /usr/local/android-sdk/emulator/lib64/gles_mesa/libGL.so.1 /usr/lib/x86_64-linux-gnu/mesa/

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
