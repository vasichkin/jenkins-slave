FROM centos:centos6
MAINTAINER Alexey Wasilyev <awasilyev@qubell.com>

ADD mongo.repo /etc/yum.repos.d/mongodb.repo
RUN yum install -y epel-release centos-release-SCL && \
    yum install -y java-1.7.0-openjdk openssh-server curl git tar sudo make patch gcc gcc-c++ python-setuptools bzip2 mongodb-org which java-1.7.0-openjdk-devel python27 rpm-build wget nodejs-0.10.33 && \
    yum localinstall -y 'https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.3/rabbitmq-server-3.5.3-1.noarch.rpm' && \
    yum localinstall -y 'https://packagecloud.io/chef/stable/download?distro=6&filename=chefdk-0.2.2-1.x86_64.rpm' && \
    yum clean all

RUN adduser jenkins && \
    sed -i 's/jenkins:!!/jenkins:np/' /etc/shadow && \
    sed -i '/requiretty/d' /etc/sudoers && \
    echo "jenkins    ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa  && \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

RUN easy_install virtualenv supervisor argparse

ADD sbt /usr/bin/
ADD https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.8/sbt-launch.jar /usr/bin/
RUN chmod +x /usr/bin/sbt && \
    chmod 755 /usr/bin/sbt-launch.jar && \
    mkdir -p /usr/share/sbt-launcher-packaging/bin && \
    ln -s /usr/bin/sbt-launch.jar /usr/share/sbt-launcher-packaging/bin/sbt-launch.jar

EXPOSE 22
ADD supervisord.conf /etc/supervisord.conf
RUN mkdir -p /data/db /var/log/supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
