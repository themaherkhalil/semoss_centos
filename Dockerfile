# docker build --no-cache --progress=plain -t rhel .
# docker build --progress=plain -t rhel .
# docker run -it -p 80:8080 rhel 

# STARTING DOCKER-TOMCAT

FROM centos:centos7.9.2009 as base

FROM semoss/docker-tomcat:debian10 as mavenpuller

# skip cache based on the semoss-artifacts 
RUN apt-get update -y \
	&& apt-get install -y curl lsof \
	&& mkdir /opt/semosshome
ADD "https://api.github.com/repos/SEMOSS/semoss-artifacts/git/refs/heads/master" skipcache
RUN cd /opt && git clone https://github.com/SEMOSS/semoss-artifacts \
	&& chmod 777 /opt/semoss-artifacts/artifacts/scripts/*.sh \
	&& /opt/semoss-artifacts/artifacts/scripts/update_latest_dev.sh \
	&& chmod 777 /opt/semosshome/config/Chromedriver/*

FROM base

ENV TOMCAT_HOME=/opt/apache-tomcat-9.0.26
ENV JAVA_HOME=/usr/lib/jvm/zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64
ENV PATH=$PATH:/opt/apache-maven-3.5.4/bin:$TOMCAT_HOME/bin:$JAVA_HOME/bin

# Install the following:
# Java - zulu https://cdn.azul.com/zulu/bin/zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64.tar.gz
# Tomcat
# Wget
# Maven
# Git
# Nano
RUN yum -y update && \
	yum -y install apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common && \
	yum -y update && \
	cd ~/ && \
	yum -y install wget && \
	yum -y install procps && \
	mkdir /usr/lib/jvm
RUN cd /usr/lib/jvm && \
	wget https://cdn.azul.com/zulu/bin/zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64.tar.gz && \
	tar -xvf zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64.tar.gz && \
	rm -rf zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64.tar.gz 
RUN java -version 

#NEED TO SEE HOW TO INSTALL THIS ON CENTOS
#RUN yum -y install libopenblas-base 

RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.26/bin/apache-tomcat-9.0.26.tar.gz && \
	tar -zxvf apache-tomcat-*.tar.gz && \
	mkdir $TOMCAT_HOME && \
	mv apache-tomcat-9.0.26/* $TOMCAT_HOME/ && \
	rm -r apache-tomcat-9.0.26 && \
	rm apache-tomcat-9.0.26.tar.gz && \
	rm $TOMCAT_HOME/conf/server.xml && \
	rm $TOMCAT_HOME/conf/web.xml && \
	yum -y install git && \
	cd $TOMCAT_HOME && \
	git config --global http.sslverify false && \
	git clone https://github.com/SEMOSS/docker-tomcat && \
	cd docker-tomcat && \
	cp ./web.xml $TOMCAT_HOME/conf/web.xml && \
	cp ./server.xml $TOMCAT_HOME/conf/server.xml && \
	cd .. && \
	rm -r docker-tomcat
RUN echo 'CATALINA_PID="$CATALINA_BASE/bin/catalina.pid"' > $TOMCAT_HOME/bin/setenv.sh 
RUN wget https://apache.claz.org/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz 
RUN tar -zxvf apache-maven-*.tar.gz 
RUN mkdir /opt/apache-maven-3.5.4 
RUN mv apache-maven-3.5.4/* /opt/apache-maven-3.5.4/ 
RUN rm -r apache-maven-3.5.4 
RUN rm apache-maven-3.5.4-bin.tar.gz 
RUN yum -y install nano 
RUN echo '#!/bin/sh' > $TOMCAT_HOME/bin/start.sh 
RUN echo 'catalina.sh start' >> $TOMCAT_HOME/bin/start.sh 
RUN echo 'tail -f /opt/apache-tomcat-9.0.26/logs/catalina.out' >> $TOMCAT_HOME/bin/start.sh 
RUN echo '#!/bin/sh' > $TOMCAT_HOME/bin/stop.sh 
RUN echo 'shutdown.sh -force' >> $TOMCAT_HOME/bin/stop.sh 
RUN chmod 777 $TOMCAT_HOME/bin/*.sh 
RUN chmod 777 /opt/apache-maven-3.5.4/bin/*.cmd 
RUN yum clean all


# STARTING DOCKER-R

# Install R
# 	(https://www.digitalocean.com/community/tutorials/how-to-install-r-on-debian-9)
# Reconfigure java for rJava
# Configure Rserve
# Install the following (needed for RCurl):
#	libssl-dev
#	libcurl4-openssl-dev
#	libxml2-dev
RUN yum -y install epel-release && \
	yum -y install R && \
	yum -y install make gcc gcc-gcc+ libcurl-devel libxml2-devel openssl-devel libssh2-devel texlive-* && \
	echo 'options(repos = c(CRAN = "http://cloud.r-project.org/"))' >> /usr/lib64/R/etc/Rprofile.site

# INSTALLING R PACKAGES

RUN wget --no-check-certificate https://github.com/gagolews/stringi/archive/master.zip -O stringi.zip && \
	unzip stringi.zip && \
	sed -i '/\/icu..\/data/d' stringi-master/.Rbuildignore && \
	R CMD build stringi-master && \
	R CMD INSTALL stringi_1.6.2.9004.tar.gz

COPY Packages.R /opt/Packages.R
RUN Rscript  /opt/Packages.R

# MOVING FINAL FILES

ENV PATH=$PATH:/opt/semoss-artifacts/artifacts/scripts
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64:/usr/lib64/R:/usr/lib64/R/library/rJava/jri
ENV R_HOME=/usr/lib64/R

RUN	mkdir /opt/semosshome \
	&& mkdir $TOMCAT_HOME/webapps/Monolith \
	&& mkdir $TOMCAT_HOME/webapps/SemossWeb \
	&& cp /usr/lib/jvm/zulu8.44.0.13-ca-fx-jdk8.0.242-linux_x64/lib/tools.jar $TOMCAT_HOME/lib \
	&& sed -i "s/tomcat.util.scan.StandardJarScanFilter.jarsToSkip=/tomcat.util.scan.StandardJarScanFilter.jarsToSkip=*.jar,/g" $TOMCAT_HOME/conf/catalina.properties;

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
	&& yum install -y google-chrome-stable_current_x86_64.rpm \
	&& rm google-chrome-stable_current_x86_64.rpm

ADD "https://api.github.com/repos/SEMOSS/semoss-artifacts/git/refs/heads/master" skipcache
RUN yum -y update \
	&& yum -y install curl lsof \
	&& cd /opt && git clone https://github.com/SEMOSS/semoss-artifacts \
	&& chmod 777 /opt/semoss-artifacts/artifacts/scripts/*.sh

COPY --from=mavenpuller /opt/semosshome /opt/semosshome
COPY --from=mavenpuller $TOMCAT_HOME/webapps/Monolith $TOMCAT_HOME/webapps/Monolith
COPY --from=mavenpuller $TOMCAT_HOME/webapps/SemossWeb $TOMCAT_HOME/webapps/SemossWeb
COPY --from=mavenpuller /opt/semoss-artifacts/ver.txt /opt/semoss-artifacts/ver.txt

WORKDIR /opt/semoss-artifacts/artifacts/scripts

CMD ["start.sh"]
