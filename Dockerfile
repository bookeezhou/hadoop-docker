FROM centos:centos7.6.1810

LABEL ZLH bookee99@163.com

WORKDIR /root

# install openssh-server, jdk
RUN yum install -y openssl openssh-server openssh-clients vim net-tools; yum clean all;

# install hadoop 3.3.1
ADD install_tar/hadoop-3.3.1.tar.gz /usr/local/
ADD install_tar/jdk-8u291-linux-x64.tar.gz /usr/local/

RUN ln -s /usr/local/hadoop-3.3.1 /usr/local/hadoop \
    && ln -s /usr/local/jdk1.8.0_291 /usr/local/jdk1.8


# set environment variable
ENV JAVA_HOME=/usr/local/jdk1.8
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${JAVA_HOME}/bin
ENV TZ="Asia/Shanghai"
ENV HADOOP_CLASSPATH=`hadoop classpath`
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cp ~/.ssh/id_rsa /etc/ssh/ssh_host_rsa_key && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd


RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/yarn-env.sh $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

