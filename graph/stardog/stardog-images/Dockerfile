# Install typical drivers
ARG STARDOG_IMAGE=stardog/stardog:8.1.0-java11-preview
# ARG STARDOG_IMAGE=stardog/stardog:8.0.0-java11-preview
FROM $STARDOG_IMAGE

USER root
RUN yum updateinfo && yum install -y iproute lsof sudo postgresql-jdbc mysql-connector-java epel-release net-tools
RUN yum install -y htop jq rsync openssh
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN groupadd sudo
RUN usermod -G sudo -a stardog
RUN mkdir -p /var/opt/drivers/
RUN chown root:stardog /var/opt/drivers
RUN cp -v /usr/share/java/mysql-connector-java.jar /usr/share/java/postgresql-jdbc.jar /var/opt/drivers/
# RUN curl -L -o /var/opt/drivers/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
RUN curl -L -o /var/opt/drivers/jts-core-1.18.1.jar https://repo1.maven.org/maven2/org/locationtech/jts/jts-core/1.18.1/jts-core-1.18.1.jar

COPY /SparkJDBC42.jar /var/opt/drivers/
COPY /sqlite-jdbc-3.36.0.3.jar /var/opt/drivers/
# COPY /mysql-connector-java-5.1.49-bin.jar /var/opt/drivers/
# COPY /mssql-jdbc-6.2.1.jre8.jar /var/opt/drivers/
ENV STARDOG_EXT=/var/opt/drivers/
