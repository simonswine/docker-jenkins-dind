# Docker image simonswine/jenkins-dind

## Introduction

Dockerfile to build a Jenkins Slave image based on[docker/1.10-dind](https://github.com/docker-library/docker/tree/master/1.10/dind).

It runs a docker daemon in docker which can be used for jenkins builds. 

The docker container needs to be run with `--privileged` and is probably a *security thread* to the docker host

## Environment variable parameters

name | description | default
--- | --- | ---
`JENKINS_PUB_KEY` | SSH public key that is used to connect to the jenkins slave *required* |
`JENKINS_USER` | name for jenkins user | `jenkins`
`JENKINS_GROUP` | name for jenkins group | `jenkins`
`JENKINS_UID` | UID for jenkins user | `999`
`JENKINS_GID` | GID for jenkins group | `999`
`JENKINS_HOME` | Home directory for jenkins user | `/jenkins`

