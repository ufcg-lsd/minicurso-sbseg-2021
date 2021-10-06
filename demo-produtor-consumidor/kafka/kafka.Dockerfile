FROM maven:3.6.0-jdk-11-slim AS build

RUN apt-get update 
RUN apt-get install git -y git
WORKDIR /
RUN git clone https://github.com/ufcg-lsd/kafka-spiffe-principal
WORKDIR /kafka-spiffe-principal
RUN mvn package

FROM openjdk:11-jre

COPY --from=build /kafka-spiffe-principal/target/kafka-spiffe-principal-2.0.0.jar /opt
RUN wget https://archive.apache.org/dist/kafka/2.7.0/kafka_2.12-2.7.0.tgz && \
    tar -xzf kafka_2.12-2.7.0.tgz && \
    cp -r kafka_2.12-2.7.0/* / && \
    rm -rf kafka_2.12-2.7.0 && \
    rm -rf kafka_2.12-2.7.0.tgz
RUN apt-get update && apt-get install -y git wget curl make gnupg2
RUN wget https://golang.org/dl/go1.13.8.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.13.8.linux-amd64.tar.gz
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin

WORKDIR /
RUN git clone https://github.com/spiffe/spiffe-helper -b 0.5
WORKDIR /spiffe-helper
RUN make

WORKDIR /
RUN mkdir -p /entrypoint
COPY kafka-entrypoint/* /entrypoint/
RUN chmod +x /entrypoint/*
ENV CLASSPATH=$CLASSPATH:/opt/kafka-spiffe-principal-2.0.0.jar
RUN mkdir -p /store

ENTRYPOINT ["/entrypoint/start.sh"]
