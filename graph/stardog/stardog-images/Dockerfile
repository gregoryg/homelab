FROM debian:stable-slim

USER root
ENV DEBIAN_FRONTEND="noninteractive"
# install a bunch of tools that may be helpful when debugging as well as
# the base krb5 env and stardog
RUN apt-get update && apt-get install -y \
    telnet \
    vim \
    htop \
    jq \
    sudo \
    rsync \
    openssh-client \
    krb5-user \
    libpam-krb5 \
    curl \
    wget \
    gnupg2 \
    systemd \
    python3-pexpect \
    unzip \
    python3 \
    python3-requests-kerberos \
    python3-requests \
    telnet \
    inetutils-ping \
    openjdk-11-jre \
    libpostgresql-jdbc-java \
    libmariadb-java
ADD stardog-latest.zip /usr/local/stardog.zip
RUN cd /usr/local && unzip stardog.zip
RUN rm -f /usr/local/stardog.zip
RUN cd /usr/local && ln -s stardog-* stardog
ADD tools /usr/tools
## Add a stardog unprivileged user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# RUN groupadd sudo
RUN groupadd -g 1000 stardog
RUN useradd -m -u 1000 -g 1000 -G sudo stardog
# RUN usermod -G sudo -a stardog
# RUN mkdir -p /var/opt/drivers/
# RUN chown root:stardog /var/opt/drivers
# RUN cp -v /usr/share/java/mysql-connector-java.jar /usr/share/java/postgresql-jdbc.jar /var/opt/drivers/
# COPY /SparkJDBC42.jar /usr/share/java/
# COPY /sqlite-jdbc-3.36.0.3.jar /usr/share/java/

ENV STARDOG_EXT=/usr/share/java/
ENV PATH=/usr/local/stardog/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
