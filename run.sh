#!/bin/bash

set -e
set -x

# get environment variables
JENKINS_USER=${JENKINS_USER:-jenkins}
JENKINS_GROUP=${JENKINS_GROUP:-jenkins}
JENKINS_UID=${JENKINS_UID:-999}
JENKINS_GID=${JENKINS_GID:-999}
JENKINS_HOME=${JENKINS_HOME:-/jenkins}

# pub key is required
[ -z "${JENKINS_PUB_KEY}" ] && echo "Need to set env variable JENKINS_PUB_KEY" && exit 1;


# Generate ssh host keys
for alg in rsa dsa ecdsa ed25519; do
    path="/etc/ssh/keys/ssh_host_${alg}_key"
    [ -e $path ] && continue
    echo "Recreate SSH host key for ${alg}"
    ssh-keygen -P "" -t $alg -f $path
done


# Create the group if not exists
if ! getent group ${JENKINS_GROUP}  > /dev/null 2>&1; then
    addgroup -g ${JENKINS_GID} ${JENKINS_GROUP}
fi

# Create the user if not exists
if ! getent passwd ${JENKINS_USER}  > /dev/null 2>&1; then
    adduser -D -s /bin/bash -G ${JENKINS_GROUP} -u ${JENKINS_UID} -h ${JENKINS_HOME} ${JENKINS_USER}

    # add user to docker group
    addgroup -S docker
    adduser ${JENKINS_USER} docker

    # unlock user
    sed -i s/${JENKINS_USER}:\!/${JENKINS_USER}:*/g /etc/shadow
fi

# Add a public key to the user
mkdir -p "${JENKINS_HOME}/.ssh"
echo "${JENKINS_PUB_KEY}" > "${JENKINS_HOME}/.ssh/authorized_keys"
chown -R ${JENKINS_USER}:${JENKINS_GROUP} "${JENKINS_HOME}/.ssh"
chown  ${JENKINS_USER}:${JENKINS_GROUP} ${JENKINS_HOME}

# Run preparation scripts of child project
[ -d /run.sh.d/ ] && for file in /run.sh.d/*; do
    . $file
done

/usr/local/bin/dockerd-entrypoint.sh &

exec /usr/sbin/sshd -D -E /dev/stderr
