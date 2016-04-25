FROM docker:1.10-dind

# Install apt dependencies
RUN apk update && \
    apk --no-cache add openssh wget ca-certificates bash git make && \
    rm -rf /tmp/*

RUN for alg in rsa dsa ecdsa ed25519; do \
    rm /etc/ssh/ssh_host_${alg}_key /etc/ssh/ssh_host_${alg}_key.pub; \
    ln -s ./keys/ssh_host_${alg}_key /etc/ssh/ssh_host_${alg}_key; \
    ln -s ./keys/ssh_host_${alg}_key.pub /etc/ssh/ssh_host_${alg}_key.pub; \
    done

RUN mkdir /var/run/sshd

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=92 \
    JAVA_BUILD=14 \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

RUN cd "/tmp" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    rm -rf "$JAVA_HOME/"*src.zip && \
    rm "/tmp/"*

# Volume with keys
VOLUME /etc/ssh/keys
VOLUME /jenkins

# Expose SSH
EXPOSE 22

# Jenkins home directory
VOLUME /jenkins

# Add run script
ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD /run.sh
