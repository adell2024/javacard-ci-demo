FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JC_HOME=/opt/java_card_kit-2_2_2
ENV PATH=$JAVA_HOME/bin:$JC_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    make \
    gcc-multilib \
    libpcsclite1 \
    pcsc-tools \
    && rm -rf /var/lib/apt/lists/*

# Copier le JCDK (à télécharger manuellement et placer à côté du Dockerfile)
COPY java_card_kit-2_2_2 /opt/java_card_kit-2_2_2

# Copier le script de test
COPY scripts/run_tests.sh /usr/local/bin/run_tests.sh
RUN chmod +x /usr/local/bin/run_tests.sh

WORKDIR /workspace
CMD ["/bin/bash"]
