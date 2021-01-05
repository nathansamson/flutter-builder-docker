FROM fedora:30

ENV ANDROID_COMPILE_SDK=30
ENV ANDROID_BUILD_TOOLS=30.0.3 
ENV ANDROID_SDK_TOOLS=6858069
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_VERSION=1.22.5-${FLUTTER_CHANNEL}

RUN dnf update -y \
    && dnf install -y wget git \
    xz tar unzip which \
    ruby ruby-devel \
    make autoconf automake  \
    redhat-rpm-config \
    lcov \
    gcc gcc-c++ libstdc++.i686 \
    java-1.8.0-openjdk-devel \
    mesa-libGL mesa-libGLU \
    && dnf clean all

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:/opt/android-sdk-linux/platform-tools/

RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/ \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platforms;android-${ANDROID_COMPILE_SDK}" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;${ANDROID_BUILD_TOOLS}" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;android;m2repository" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;google_play_services" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;m2repository" \
    && yes | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses || echo "Failed" \
    && rm android-sdk.zip

RUN wget --quiet --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz

ENV PATH=$PATH:/opt/flutter/bin

RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "emulator" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-18;google_apis;x86" \
    && echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-27;google_apis_playstore;x86"

RUN dnf update -y \
    && dnf install -y pulseaudio-libs mesa-libGL  mesa-libGLES mesa-libEGL \
    && dnf clean all

#
# /opt/android-sdk-linux/tools/bin/avdmanager create avd -k 'system-images;android-18;google_apis;x86' --abi google_apis/x86 -n 'test' -d 'Nexus 4'
# emulator -avd test -no-skin -no-audio -no-window
