FROM jenkins/jenkins:alpine
LABEL maintainer="Muhammad Fahrizal Rahman m[dot]fahrizal[at]orami[dot]com"

USER root

RUN apk update && apk upgrade

RUN apk add curl net-tools wget git py-pip sudo shadow
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \ 
    unzip awscli-bundle.zip && \
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Update apk repositories
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-2.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install the latest Docker and docker-compose binaries
RUN apk -U --no-cache \
	--allow-untrusted add \
    gcc \
    docker \
    py-pip python-dev libffi-dev openssl-dev libc-dev make \
    && pip install docker-compose \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN apk add --update shadow \
    && groupadd -g 50 staff \
    && usermod -a -G staff jenkins \
    && usermod -aG docker jenkins

# if none of those command above work, you need to:
# - login to your container and do:
#  - usermod -a -G staff jenkins
#  - usermod -aG users jenkins
#  - usermod -aG docker jenkins
#  - reboot
#  - restart docker service on host
#  or.. this will work but This gives anyone root on your system. 
#  They are able to talk to docker and create privileged containers with no restrictions.
#  chmod 777 /var/run/docker.sock

USER jenkins
RUN  pip install redis --user
