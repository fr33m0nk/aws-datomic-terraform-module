#!/bin/bash

sleep 5

# Export JVM XMX as environment variable
export XMX="-Xmx${jvm_xmx}"
echo "export XMX=$XMX" | tee -a /etc/environment
su - ${distro_user} -c "export XMS="-Xms${jvm_xms}""

# Export JVM XMS as environment variable
export XMS="-Xms${jvm_xms}"
echo "export XMS=$XMS" | tee -a /etc/environment
su - ${distro_user} -c "export XMS="-Xms${jvm_xms}""

## CD into /opt/datomic_pro
cd /opt/datomic_pro || return

# Export JAVA_OPTS as environment variable
echo "${java_opts}" | tee java_opts.properties
export JAVA_OPTS=$(cat java_opts.properties)
echo "export JAVA_OPTS=$JAVA_OPTS" | tee -a /etc/environment
su - ${distro_user} -c "export JAVA_OPTS=$(cat /opt/datomic_pro/java_opts.properties)"

# Export LOG_LEVEL in environmeny
export LOG_LEVEL="${log_level}"
echo "export LOG_LEVEL=$LOG_LEVEL" | tee -a /etc/environment
su - ${distro_user} -c "export LOG_LEVEL="${log_level}""

## Create a config file to run Datomic with
cat <<EOF >/opt/datomic_pro/aws_transactor.properties
protocol=${protocol}
port=4334
host=`curl http://instance-data/latest/meta-data/local-ipv4`
alt-host=`curl http://instance-data/latest/meta-data/public-ipv4`
license-key=${datomic_license}
aws-dynamodb-table=${aws_dynamodb_table}
aws-dynamodb-region=${aws_dynamodb_region}
aws-transactor-role=${transactor_role}
aws-peer-role=${peer_role}
memory-index-max=${memory_index_max}
memory-index-threshold=${memory_index_threshold}
object-cache-max=${object_cache_max}
encrypt-channel=true
memcached=${memcached_uri}
memcached-auto-discovery=true
aws-s3-log-bucket-id=${s3_log_bucket_id}
aws-cloudwatch-region=${cloudwatch_region}
aws-cloudwatch-dimension-value=${cloudwatch_dimension}
write-concurrency=${write-concurrency}
read-concurrency=${read-concurrency}
heartbeat-interval-msec=5000
metrics-callback=fr33m0nk.datomic-datadog-reporter/send-metrics
EOF

## Set correct permissions
chmod 744 /opt/datomic_pro/aws_transactor.properties
chown -R ${distro_user}:datomic /opt/datomic_pro

## start datadog agent
systemctl start datadog-agent

# Start transactor process
su - ubuntu -c "/opt/datomic_pro/bin/transactor /opt/datomic_pro/aws_transactor.properties" || true
echo "Transactor process stopped. Shutting down."
shutdown -h now
