FROM debian:stretch-slim

ENV SCALA_VERSION 2.12
ENV KAFKA_VERSION 1.1.0
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		vim procps wget iputils-ping dnsutils uuid-runtime kafkacat

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
	
RUN mkdir /usr/share/man/man1 -p
RUN apt-get install -y --no-install-recommends openjdk-8-jre-headless libcap2-bin

# kafka offline version available in ./kafka-src
#RUN wget -q http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz 
COPY ./kafka-src/kafka_2.12-1.1.0.tgz /tmp/  
RUN tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt && \
    rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz

ADD scripts/start-kafka_mirror_maker.sh /usr/bin/start-kafka_mirror_maker.sh

RUN ln -s "$KAFKA_HOME/logs" /var/log/kafka-logs

# Supervisor config
ADD configs/supervisor/kafka_mirror_maker.conf /etc/supervisor/conf.d/
# Vim configuration
ADD configs/vim/.vimrc /root/.vimrc

RUN ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo Europe/Paris > /etc/timezone

# 2181 is zookeeper, 9092/9094 is kafka, 9001 is JMX
EXPOSE 9092 9094 9001

VOLUME ["/etc/mirrormaker"]

CMD ["/usr/bin/supervisord","-n"]
