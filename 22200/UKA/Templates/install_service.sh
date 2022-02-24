export PACKAGE_VERSION={{suiteversion}}
export UKA_SERVER_NODES="{{UKASERVERNODES}}" #"192.168.3.25:9092,192.168.3.26:9092,192.168.3.27:9092"
export KAFKA_LOCATION="/opt/kafka/kafka_2.12-3.0.0/bin/" #"/opt/kafka/kafka_2.12-3.0.0/bin"
export PACKAGE_ROOT_LINUX="{{packageroot}}" #"/opt/install/"

python ${PACKAGE_ROOT_LINUX}${PACKAGE_VERSION}/UKA/Package/topics/kafka_addalter_topics.py -t ${PACKAGE_ROOT_LINUX}${PACKAGE_VERSION}/UKA/Package/topics/topics.json -b ${UKA_SERVER_NODES}

