FROM fedora:30

ENV ANDROID_COMPILE_SDK=28
ENV ANDROID_BUILD_TOOLS=28.0.1
ENV ANDROID_SDK_TOOLS=4333796
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_VERSION=1.7.8+hotfix.4-${FLUTTER_CHANNEL}

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

RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/ \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;google_play_services" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;m2repository" \
    && yes | /opt/android-sdk-linux/tools/bin/sdkmanager  --licenses || echo "Failed" \
    && rm android-sdk.zip

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:/opt/android-sdk-linux/platform-tools/

RUN wget --quiet --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_v${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz

ENV PATH=$PATH:/opt/flutter/bin

RUN echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "emulator" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-18;google_apis;x86" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-27;google_apis_playstore;x86"

RUN dnf update -y \
    && dnf install -y pulseaudio-libs mesa-libGL  mesa-libGLES mesa-libEGL \
    && dnf clean all

#
# /opt/android-sdk-linux/tools/bin/avdmanager create avd -k 'system-images;android-18;google_apis;x86' --abi google_apis/x86 -n 'test' -d 'Nexus 4'
# emulator -avd test -no-skin -no-audio -no-window
