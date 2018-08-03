#!/bin/bash

DATE_STR=`date '+%Y%m%d_%H%M%S'`

DEFAULT_PRODUCERS=1
DEFAULT_STREAMS=1
UUID=$(uuidgen)
DEFAULT_CONSUMER_GROUP_ID="Mirror_${UUID}_${DATE_STR}"
DEFAULT_PRODUCER_CLIENT_ID="Mirror_${UUID}_${DATE_STR}"

DEFAULT_OFFSET_RESET="largest"

if [ -n "$WHITE_LIST" ]; then
    WHITE_LIST="--whitelist $WHITE_LIST"
fi

if [ -n "$BLACK_LIST" ]; then
    BLACK_LIST="--blacklist $BLACK_LIST"
fi

if [ -z "$PRODUCER_COUNT" ]; then
    PRODUCER_COUNT=$DEFAULT_PRODUCERS
fi

if [ -z "$STREAM_COUNT" ]; then
    STREAM_COUNT=$DEFAULT_STREAMS
fi

if [ -z "$CONSUMER_GROUP_ID" ]; then
    CONSUMER_GROUP_ID=$DEFAULT_GROUP_ID
fi

if [ -z "$SOURCE_BROKERS" ]; then
    echo "Specify SOURCE_BROKERS connection string"
    exit 2
fi

if [ -z "$DESTINATION_BROKERS" ]; then
    echo "Specify DESTINATION_BROKERS connection string"
    exit 3
fi


cat <<- EOF > /etc/mirrormaker/consumer.config
    bootstrap.servers=$SOURCE_BROKERS
    group.id=$DEFAULT_CONSUMER_GROUP_ID
    auto.commit.enabled=false
EOF


cat <<- EOF > /etc/mirrormaker/producer.config
    bootstrap.servers=$DESTINATION_BROKERS
    client.id=$DEFAULT_PRODUCER_CLIENT_ID
    block.on.buffer.full=true
    acks=-1
    max.in.flight.requests.per.connection=1


EOF
/bin/bash -C $KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.MirrorMaker \
$WHITE_LIST \
--consumer.config /etc/mirrormaker/consumer.config \
--producer.config /etc/mirrormaker/producer.config \
--abort.on.send.failure true \ 
