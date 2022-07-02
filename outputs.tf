output "datomic_transactor" {
  description = "Properties of resources provisioned for Datomic Transactor"
  value = {
    s3_logs              = aws_s3_bucket.datomic_transactor_logs
    security_group       = aws_security_group.datomic_transactor_security_group
    iam_role             = aws_iam_role.datomic_transactor_iam_role
    iam_instance_profile = aws_iam_instance_profile.datomic_transactor_instance_profile
    launch_config        = aws_launch_configuration.datomic_transactor_launch_config
    autoscaling_group    = aws_autoscaling_group.datomic_transactors_autoscaling_group
  }
}

output "datomic_peer" {
  description = "Properties of resources provisioned for Datomic Peer"
  value = {
    iam_policy = aws_iam_policy.datomic_peer_access_policy
    iam_policy_attachment = aws_iam_policy_attachment.datomic_peer_access_policy_attachment
  }
}

output "datomic_transactor_dynamo_db" {
  description = "Properties of Dynamo DB resources provisioned for Datomic Transactor"
  value = {
    table                          = aws_dynamodb_table.datomic_dynamo_db_table
    table_read_autoscaling_target  = aws_appautoscaling_target.datomic_dynamo_db_table_read_autoscaling_target
    table_read_autoscaling_policy  = aws_appautoscaling_policy.datomic_dynamo_db_table_read_autoscaling_policy
    table_write_autoscaling_target = aws_appautoscaling_target.datomic_dynamo_db_table_write_autoscaling_target
    table_write_autoscaling_policy = aws_appautoscaling_policy.datomic_dynamo_db_table_write_autoscaling_policy
  }
}

output "datomic_transactor_memcached" {
  description = "Properties of Dynamo DB resources provisioned for Datomic Transactor"
  value = {
    cluster_security_group = aws_security_group.datomic_memcached_cluster_security_group
    cluster                = aws_elasticache_cluster.datomic_memcached_cluster
  }
}
