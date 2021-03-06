FROM python:3-buster

RUN apt-get update && \
    apt-get install -y git \
    lib32stdc++6 \
    lib32gcc1 \
    lib32z1 \
    lib32ncurses6 \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    libxml2-dev \
    libxslt1-dev \
    openjdk-11-jdk-headless \
    virtualenv \
    wget \
    unzip \
    zlib1g-dev \
    less \
    mc \
    nano \
    android-sdk-platform-tools \
    android-sdk-build-tools && \
    rm -rf /var/lib/apt/lists

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip \
    && unzip commandlinetools-linux-6609375_latest.zip \
    && rm commandlinetools-linux-6609375_latest.zip

RUN mkdir /opt/android-sdk-linux \
    && mv tools /opt/android-sdk-linux/tools

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:$ANDROID_HOME/tools

RUN echo 'y' | /opt/android-sdk-linux/tools/bin/sdkmanager --sdk_root=/opt/android-sdk-linux --verbose --install "platforms;android-30" "build-tools;30.0.1"

RUN echo 'y' | rm -rf tools

RUN mkdir -p /data/fdroid/repo && \
    mkdir -p /opt/playmaker

WORKDIR /opt/playmaker

COPY README.md setup.py pm-server /opt/playmaker/
COPY playmaker /opt/playmaker/playmaker


RUN pip3 install .
    #cd /opt && rm -rf playmaker

RUN pip3 install fdroidserver
RUN pip3 install Cython && \
    pip3 install . && \
    cd /opt && rm -rf playmaker

RUN groupadd -g 999 pmuser && \
    useradd -m -u 999 -g pmuser pmuser
RUN chown -R pmuser:pmuser /data/fdroid && \
    chown -R pmuser:pmuser /opt/playmaker
RUN mkdir -p /usr/local/share/doc/fdroidserver/
RUN ln -s /data/fdroid /usr/local/share/doc/fdroidserver/examples
USER pmuser

VOLUME /data/fdroid
WORKDIR /data/fdroid
RUN touch /data/fdroid/fdroid-icon.png
RUN touch /data/fdroid/config.py

EXPOSE 5000
ENTRYPOINT python3 -u /usr/local/bin/pm-server --fdroid --debug
