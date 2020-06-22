FROM ubuntu:20.04

ARG SPARK_VER=2.4.6

WORKDIR /root
ENV http_proxy http://172.16.17.4:3128
ENV https_proxy http://172.16.17.4:3128

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install python 3.7 (3.8 does not work with current pyspark 2.4.6 - as of 2020-06-21)
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa

# Install a base time build environment
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apt-utils \
	build-essential \
	curl \
    git \
    jq \
	libpng-dev \
	libfreetype6-dev \
    pkg-config \
    python3 \
	python3.7 \
    python3.7-dev \
    python3-pip \
	python3-distutils \
	software-properties-common \
	sudo \
	tar \
	unzip \
	wget && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

#
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 10

# run as unprivileged user in container!
RUN groupadd -g 1042 gregj && \
    useradd -g 1042 --uid 1042 --create-home --shell /usr/bin/bash gregj && \
    echo "gregj ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/gregj && \
    chmod 0440 /etc/sudoers.d/gregj
# TODO ?? set up user for sudo 

# # Get the latest pip3
# RUN wget -q https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py

# Install python3 infrastructure
COPY requirements.txt .
RUN pip3 --no-cache-dir install -r requirements.txt && rm -f requirements.txt

# Install Spark dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	openjdk-8-jre \
	scala && \
	apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install Spark
RUN wget -q -O spark.tgz http://mirror.olnevhost.net/pub/apache/spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop2.7.tgz && \
	mkdir -p /usr/local && tar -xf spark.tgz -C /usr/local && \
	mv /usr/local/spark*${SPARK_VER}* /usr/local/spark && \
    	pip3 install --upgrade pyspark

# Clean up
RUN rm -rf /root/* && chmod 755 /root

RUN su - gregj -c "jupyter notebook --generate-config"
RUN su - gregj -c "sed -i -E 's,^#\s*c.NotebookApp.terminado_settings.*,c.NotebookApp.terminado_settings = {\"shell_command\" : [\"\/bin\/bash\"]},g' ~/.jupyter/jupyter_notebook_config.py"

# Setup password authentication so we don't have to remember tokens (password: "jupyter")
RUN su - gregj -c 'echo "{ \"NotebookApp\": { \"password\": \"sha1:ad16e87de314:a02efac10ccd7ead24e845f438b2b87fe8bc2d0f\" } }" >> ~/.jupyter/jupyter_notebook_config.json'
RUN su - gregj -c 'mkdir -p ~/.ipython/profile_default'

# Required spark configuration for local user access
ENV SPARK_HOME=/usr/local/spark
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3
ENV PYTHONPATH=/usr/local/spark/python:/usr/local/spark/python/lib/py4j-0.10.7-src.zip
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/spark/bin

EXPOSE 4040 4041 8080 8888 

USER gregj
WORKDIR /home/gregj
CMD ["notebook", "--no-browser", "--ip=0.0.0.0", "--port=8888"]
ENTRYPOINT ["/usr/local/bin/jupyter"]
