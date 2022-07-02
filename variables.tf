variable "aws_region" {
  type        = string
  description = "AWS region in which resources for Datomic get provisioned"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID in which resources for Datomic get provisioned. If not provided uses the ID of the default VPC"
}

################################
### Datomic peer vars
variable "datomic_peer_security_group_id" {
  type        = string
  description = "Security group id already applied to peer to allow communication to Datomic transactor and related resources"
}

variable "datomic_peer_iam_role_name" {
  type        = string
  description = "IAM role name of a role already applied to Peer. Serves as the Peer role name in Datomic Transactor configuration"
}

################################
### Datomic transactor vars
variable "datomic_transactor_ami_name" {
  type        = string
  description = "AMI name for the transactor. If AMI is ARM based, then select appropriate `datomic_transactor_instance_type`"
}

variable "datomic_transactor_ami_owner_id" {
  type        = string
  description = "Owner ID of AMI for the transactor"
}

variable "datomic_transactor_ami_user" {
  type        = string
  description = "AMI user with privileges for starting a Java process"
}

variable "datomic_transactor_enable_custom_metric_callback" {
  type        = bool
  description = "Enables custom Metric callback library for emitting stats to Datadog, Prometheus etc. Must be available on Datomic Transactor Classpath. Example: https://github.com/fr33m0nk/datomic-datadog-reporter"
  default     = false
}

variable "datomic_transactor_metric_callback_library" {
  type        = string
  description = "Metric callback library for emitting stats to Datadog, Prometheus etc. Must be available on Datomic Transactor Classpath. Example: https://github.com/fr33m0nk/datomic-datadog-reporter"
  default     = ""
}

variable "datomic_transactor_enable_datadog" {
  type        = bool
  description = "Enables Datadog if set to true and Datadog is installed in Datomic Transactor AMI"
  default     = false
}

variable "datomic_transactor_instance_type" {
  type        = string
  description = "EBS optimised instance. Refer https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html"
}

variable "datomic_transactor_volume_type" {
  type        = string
  description = "Volume type to be used as root volume, e.g. io1"
}

variable "datomic_transactor_jvm_xmx" {
  type        = string
  description = "Datomic transactor -Xmx configuration. Ballpark the value at 70% of total RAM"
}

variable "datomic_transactor_jvm_xms" {
  type        = string
  description = "Datomic transactor -Xms configuration"
}

variable "datomic_transactor_java_opts" {
  type        = string
  description = "JAVA_OPTS for launching Datomic transactor"
  default     = "-XX:+UseG1GC -XX:MaxGCPauseMillis=50 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=7199 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

}

variable "datomic_transactor_log_level" {
  type        = string
  description = "Datomic transactor log level"
}

variable "datomic_transactor_memory_index_threshold" {
  type        = string
  description = "Datomic Memory index size threshold"
}

variable "datomic_transactor_memory_index_max" {
  type        = string
  description = "Datomic Memory index max size"
}

variable "datomic_transactor_object_cache_max" {
  type        = string
  description = "Datomic transactor Object cache max size"
}

variable "datomic_license" {
  type        = string
  description = "Datomic licence key"
}

variable "datomic_transactor_root_volume_size" {
  type        = number
  description = "The size of the Datomic Transactor's root volume in gigabytes"
}

variable "datomic_transactor_root_iops" {
  type        = number
  description = "The amount of provisioned IOPS for Datomic Transactor's root volume. Refer https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html"
}

variable "datomic_transactor_write_concurrency" {
  type        = number
  description = "Write concurrency factor for Transactor. Refer https://docs.datomic.com/on-prem/operation/capacity.html"
}

variable "datomic_transactor_read_concurrency" {
  type        = number
  description = "Read concurrency factor for Transactor. Generally twice of write concurrency. Refer https://docs.datomic.com/on-prem/operation/capacity.html"
}

variable "datomic_transactors_max_instance_count" {
  type        = number
  description = "The maximum size of the Auto Scaling Group"
  default     = 3
}

variable "datomic_transactors_min_instance_count" {
  type        = number
  description = "The minimum size of the Auto Scaling Group. Also serves as the desired capacity"
  default     = 2
}

################################
### Dynamo DB vars
variable "datomic_dynamo_db_table_read_autoscaling_min_capacity" {
  type        = number
  description = "Minimum value for the read capacity for autoscaling. Also serves as base Dynamo DB Table read capacity"
}

variable "datomic_dynamo_db_table_read_autoscaling_max_capacity" {
  type        = number
  description = "Maximum value for the read capacity for autoscaling"
}

variable "dynamo_db_table_read_autoscaling_scale_in_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a read capacity scale in activity completes before another scale in activity can start"
}

variable "dynamo_db_table_read_autoscaling_scale_out_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a read capacity scale out activity completes before another scale out activity can start"
}

variable "dynamo_db_table_read_autoscaling_target_value" {
  type        = number
  description = "The target value (%age) for triggering autoscaling of read capacity"
}

variable "datomic_dynamo_db_table_write_autoscaling_min_capacity" {
  type        = number
  description = "Minimum value for the write capacity for autoscaling. Also serves as base Dynamo DB Table write capacity"

}

variable "datomic_dynamo_db_table_write_autoscaling_max_capacity" {
  type        = number
  description = "Maximum value for the write capacity for autoscaling"
}

variable "dynamo_db_table_write_autoscaling_scale_in_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a write capacity scale in activity completes before another scale in activity can start"
}

variable "dynamo_db_table_write_autoscaling_scale_out_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a write capacity scale out activity completes before another scale out activity can start"
}

variable "dynamo_db_table_write_autoscaling_target_value" {
  type        = number
  description = "The target value (%age) for triggering autoscaling of write capacity"
}

################################
#### Elasticache using Memcached
variable "memcached_version" {
  type        = string
  description = "Version of the engine of elasticache. https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/supported-engine-versions.html"
}

variable "memcached_exposed_port" {
  type        = number
  description = "Port exposed for accessing the cluster"
  default     = 11211
}

variable "memcached_instance_type" {
  type        = string
  description = "Instance type to be used for the nodes of the cluster"
}

variable "memcached_az_mode" {
  type        = string
  description = "Whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. Valid values for this parameter are 'single-az' or 'cross-az'"
}

variable "memcached_number_of_instances" {
  type        = number
  description = "No of nodes in the cluster"
}

variable "memcached_parameter_group_name" {
  type        = string
  description = "Name of the parameter group to associate with this cache cluster. Read more https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group"
}

variable "memcached_apply_changes_immediately" {
  type        = bool
  description = "Applies changes immediately if true else the changes are applied in the next maintenance window"
}
