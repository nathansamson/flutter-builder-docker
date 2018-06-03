FROM fedora:28

ENV ANDROID_COMPILE_SDK=27
ENV ANDROID_BUILD_TOOLS=27.0.3
ENV ANDROID_SDK_TOOLS=3859397
ENV FLUTTER_VERSION=0.4.4-beta

RUN dnf update -y \
    && dnf install -y wget tar unzip ruby ruby-devel make autoconf automake redhat-rpm-config \
           gcc gcc-c++ libstdc++.i686 java-1.8.0-openjdk-devel xz git \
    && dnf clean all

RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/ \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;google_play_services" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;m2repository" \
    && yes | /opt/android-sdk-linux/tools/bin/sdkmanager  --licenses || echo "Failed"

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:/opt/android-sdk-linux/platform-tools/

RUN wget --quiet --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/beta/linux/flutter_linux_v${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter.tar.xz -C /opt \

ENV PATH=$PATH:/opt/flutter/bin 
