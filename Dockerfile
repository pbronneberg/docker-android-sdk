FROM openjdk:8-jdk

LABEL de.mindrunner.android-docker.flavour="built-in"

ENV ANDROID_SDK_VERSION 26
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

RUN groupadd -g 10000 jenkins && useradd -c "Jenkins user" -d /home/jenkins -u 10000 -g 10000 -m jenkins && \
    groupadd -g 10001 android && useradd -c "Android SDK user" -d /opt/android-sdk-linux -u 10001 -g 10001 -m android

# ------------------------------------------------------
# --- Install required tools
# Dependencies to execute Android builds
#RUN dpkg --add-architecture i386
#RUN apt-get update -qq
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

RUN apt-get update -qq \
    && apt-get install -y wget expect git curl unzip bash \
    && apt-get clean \
    && curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar

ARG AGENT_WORKDIR=/home/jenkins/agent
COPY tools /opt/tools
COPY licenses /opt/licenses

USER jenkins
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/jenkins/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/jenkins
WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in
CMD /opt/tools/entrypoint.sh built-in