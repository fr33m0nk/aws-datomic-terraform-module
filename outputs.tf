output "aws_datomic_transactor" {
  description = "Properties of resources provisioned for Datomic cluster"
  value = {
    datomic_memcached_cluster_security_group = aws_security_group.datomic_memcached_cluster_security_group
    s3_logs                                  = aws_s3_bucket.datomic_transactor_logs
    security_group                           = aws_security_group.datomic_transactor_security_group
    iam_role                                 = aws_iam_role.datomic_transactor_iam_role
    instance_profile                         = aws_iam_instance_profile.datomic_transactor_instance_profile
    launch_config                            = aws_launch_configuration.datomic_transactor_launch_config
    autoscaling_group                        = aws_autoscaling_group.datomic_transactors_autoscaling_group
    peer_iam_policy                          = aws_iam_policy.datomic_peer_access_policy
    dynamo_db = {
      table                          = aws_dynamodb_table.datomic_dynamo_db_table
      table_read_autoscaling_target  = aws_appautoscaling_target.datomic_dynamo_db_table_read_autoscaling_target
      table_read_autoscaling_policy  = aws_appautoscaling_policy.datomic_dynamo_db_table_read_autoscaling_policy
      table_write_autoscaling_target = aws_appautoscaling_target.datomic_dynamo_db_table_write_autoscaling_target
      table_write_autoscaling_policy = aws_appautoscaling_policy.datomic_dynamo_db_table_write_autoscaling_policy
    }
    memcached = {
      cluster_security_group = aws_security_group.datomic_memcached_cluster_security_group
      cluster                = aws_elasticache_cluster.datomic_memcached_cluster
    }
  }
}
