FROM docker:1.10-dind

# Install apt dependencies
RUN apk update && \
    apk --no-cache add openssh openjdk8-jre bash && \
    rm -rf /tmp/*

RUN for alg in rsa dsa ecdsa ed25519; do \
    rm /etc/ssh/ssh_host_${alg}_key /etc/ssh/ssh_host_${alg}_key.pub; \
    ln -s ./keys/ssh_host_${alg}_key /etc/ssh/ssh_host_${alg}_key; \
    ln -s ./keys/ssh_host_${alg}_key.pub /etc/ssh/ssh_host_${alg}_key.pub; \
    done

RUN mkdir /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

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
