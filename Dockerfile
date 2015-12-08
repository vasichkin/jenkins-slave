FROM centos:centos7
MAINTAINER Alexey Wasilyev <awasilyev@qubell.com>

ADD mongo.repo /etc/yum.repos.d/mongodb.repo
ADD https://bintray.com/sbt/rpm/rpm /etc/yum.repos.d/bintray-sbt-rpm.repo

RUN yum install -y epel-release centos-release-SCL && \
    yum install -y --enablerepo=epel-testing \
                   java-1.7.0-openjdk-devel java-1.8.0-openjdk-devel sbt \
                   openssh-server curl git tar sudo make patch gcc gcc-c++ bzip2 \
                   mongodb-org which python27 rpm-build http-parser libuv wget nodejs npm Xvfb libxslt-devel libxml2-devel python-devel python-pip \ 
                   jq docker-io python-lxml python-unittest2 python-paramiko python-setuptools python-boto python-mock python-nose python-simplejson pyyaml \
                   python-testtools && \
    yum localinstall -y 'https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.3/rabbitmq-server-3.5.3-1.noarch.rpm' && \
    yum localinstall -y 'https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/chefdk-0.10.0-1.el7.x86_64.rpm' && \
    yum localinstall -y 'http://downloads.onrooby.com/chromium/rpms/chromium-browser-38.0.2125.104-1.el7.centos.x86_64.rpm' && \
    yum clean all

RUN pip install awscli ansible

RUN ln -s /usr/bin/chromium-browser /usr/bin/google-chrome && \
    ln -s /opt/chromium-browser/chromedriver /usr/bin/chromedriver

RUN adduser jenkins && \
    sed -i 's/jenkins:!!/jenkins:np/' /etc/shadow && \
    sed -i '/requiretty/d' /etc/sudoers && \
    echo "jenkins    ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa  && \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

RUN easy_install virtualenv supervisor argparse

ADD rpmbuild /usr/local/bin/
RUN chmod +x /usr/local/bin/rpmbuild

ADD sbt /usr/local/bin/
RUN chmod +x /usr/local/bin/sbt

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

EXPOSE 22
ADD supervisord.conf /etc/supervisord.conf
RUN mkdir -p /data/db /var/log/supervisor

# fix https://github.com/ansible/ansible-modules-core/issues/2043
# remove after ansible-1.9.5 released
ADD https://raw.githubusercontent.com/ansible/ansible-modules-core/devel/cloud/docker/docker.py /usr/lib/python2.7/site-packages/ansible/modules/core/cloud/docker/docker.py
RUN chmod 644 /usr/lib/python2.7/site-packages/ansible/modules/core/cloud/docker/docker.py

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
