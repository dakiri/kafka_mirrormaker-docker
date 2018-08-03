# Build

make build

# Run

make run

# Services

Supervisord monitor /usr/bin/start-kafka_mirror_maker.sh 
responsible for generate configuration file :

* /etc/mirrormaker/consumer.config 

* /etc/mirrormaker/producer.config

And launching the mirrormaker.

