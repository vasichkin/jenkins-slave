FROM centos:centos6
MAINTAINER Alexey Wasilyev <awasilyev@qubell.com>

ADD mongo.repo /etc/yum.repos.d/mongodb.repo
RUN yum install -y epel-release
RUN yum install -y centos-release-SCL
RUN yum install -y java-1.7.0-openjdk openssh-server curl git tar sudo make patch gcc gcc-c++ python-setuptools bzip2 mongodb-org which java-1.7.0-openjdk-devel python27
RUN yum localinstall -y https://www.rabbitmq.com/releases/rabbitmq-server/v3.3.5/rabbitmq-server-3.3.5-1.noarch.rpm
RUN easy_install virtualenv supervisor argparse
ADD supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/run/sshd
RUN adduser jenkins
RUN yum localinstall -y 'https://packagecloud.io/chef/stable/download?distro=6&filename=chefdk-0.2.2-1.x86_64.rpm'
ADD sbt /usr/bin/
ADD https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.6/sbt-launch.jar /usr/bin/
RUN chmod +x /usr/bin/sbt
RUN chmod 755 /usr/bin/sbt-launch.jar
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN sed -i 's/jenkins:!!/jenkins:np/' /etc/shadow
RUN mkdir -p /data/db /var/log/supervisor
RUN sed -i '/requiretty/d' /etc/sudoers
RUN echo "jenkins    ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN mkdir -p /usr/share/sbt-launcher-packaging/bin/
RUN ln -s /usr/bin/sbt-launch.jar /usr/share/sbt-launcher-packaging/bin/sbt-launch.jar
RUN yum install -y rpm-build wget
EXPOSE 22
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
#CMD ["/usr/sbin/sshd", "-o UsePrivilegeSeparation=no", "-o UsePAM=no", "-D"]
