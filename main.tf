resource "aws_security_group" "datomic_transactor_security_group" {
  name        = "${terraform.workspace}_datomic_transactor_security_group"
  description = "Security group for Datomic transactors for env: ${terraform.workspace}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow ingress from Datomic tranactors for gossip protocol for env: ${terraform.workspace}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow ingress from Peers for env: ${terraform.workspace}"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.datomic_peer_security_group_id]
  }

  egress {
    description = "Allow egress from Datomic tranactors for env: ${terraform.workspace}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_transactor_security_group"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "datomic_memcached_cluster_security_group" {
  name        = "${terraform.workspace}_datomic_memcached_cluster_security_group"
  description = "Security group for Memcached cluster for Datomic for env: {terraform.workspace}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress on port ${var.memcached_exposed_port} from Datomic transactors for env: ${terraform.workspace}"
    from_port       = var.memcached_exposed_port
    to_port         = var.memcached_exposed_port
    protocol        = "tcp"
    security_groups = [aws_security_group.datomic_transactor_security_group.id]
  }

  ingress {
    description     = "Allow ingress on port ${var.memcached_exposed_port} from Peers for env: ${terraform.workspace}"
    from_port       = var.memcached_exposed_port
    to_port         = var.memcached_exposed_port
    protocol        = "tcp"
    security_groups = [var.datomic_peer_security_group_id]
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_memcached_cluster_security_group"
    Environment = terraform.workspace
  }
}

resource "aws_elasticache_cluster" "datomic_memcached_cluster" {
  cluster_id           = "${terraform.workspace}-datomic-memcached-cluster"
  engine               = "memcached"
  engine_version       = var.memcached_version
  node_type            = var.memcached_instance_type
  num_cache_nodes      = var.memcached_number_of_instances
  parameter_group_name = var.memcached_parameter_group_name
  port                 = var.memcached_exposed_port
  apply_immediately    = var.memcached_apply_changes_immediately
  az_mode              = var.memcached_az_mode
  security_group_ids = [
    aws_security_group.datomic_memcached_cluster_security_group.id
  ]

  tags = {
    Name        = "${terraform.workspace}_datomic_memcached_cluster"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket" "datomic_transactor_logs" {
  bucket        = "${terraform.workspace}-datomic-transactor-logs"
  force_destroy = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_transactor_logs"
    Environment = terraform.workspace
  }
}

resource "aws_dynamodb_table" "datomic_dynamo_db_table" {
  name           = "${terraform.workspace}_datomic_dynamo_db_table"
  billing_mode   = "PROVISIONED"
  hash_key       = "id"
  read_capacity  = var.datomic_dynamo_db_table_read_autoscaling_min_capacity
  write_capacity = var.datomic_dynamo_db_table_write_autoscaling_min_capacity
  stream_enabled = false

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_dynamo_db_table"
    Environment = terraform.workspace
  }
}

resource "aws_appautoscaling_target" "datomic_dynamo_db_table_read_autoscaling_target" {
  min_capacity       = var.datomic_dynamo_db_table_read_autoscaling_min_capacity
  max_capacity       = var.datomic_dynamo_db_table_read_autoscaling_max_capacity
  resource_id        = "table/${aws_dynamodb_table.datomic_dynamo_db_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "datomic_dynamo_db_table_read_autoscaling_policy" {
  name               = "${terraform.workspace}_datomic_dynamo_db_table_read_autoscaling_policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.datomic_dynamo_db_table_read_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.datomic_dynamo_db_table_read_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.datomic_dynamo_db_table_read_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    scale_in_cooldown  = var.dynamo_db_table_read_autoscaling_scale_in_cooldown
    scale_out_cooldown = var.dynamo_db_table_read_autoscaling_scale_out_cooldown
    target_value       = var.dynamo_db_table_read_autoscaling_target_value
  }
}

resource "aws_appautoscaling_target" "datomic_dynamo_db_table_write_autoscaling_target" {
  min_capacity       = var.datomic_dynamo_db_table_write_autoscaling_min_capacity
  max_capacity       = var.datomic_dynamo_db_table_write_autoscaling_max_capacity
  resource_id        = "table/${aws_dynamodb_table.datomic_dynamo_db_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "datomic_dynamo_db_table_write_autoscaling_policy" {
  name               = "${terraform.workspace}_datomic_dynamo_db_table_write_autoscaling_policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.datomic_dynamo_db_table_write_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.datomic_dynamo_db_table_write_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.datomic_dynamo_db_table_write_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    scale_in_cooldown  = var.dynamo_db_table_write_autoscaling_scale_in_cooldown
    scale_out_cooldown = var.dynamo_db_table_write_autoscaling_scale_out_cooldown
    target_value       = var.dynamo_db_table_write_autoscaling_target_value
  }
}

resource "aws_iam_role" "datomic_transactor_iam_role" {
  max_session_duration = "3600"
  name                 = "${terraform.workspace}_datomic_transactor_iam_role"
  path                 = "/"
  assume_role_policy   = jsonencode(local.datomic_transactor_assume_iam_role_policy)

  inline_policy {
    name   = "${terraform.workspace}_datomic_transactor_s3_logs_access_policy"
    policy = jsonencode(local.datomic_transactor_s3_logs_access_policy)
  }

  inline_policy {
    name   = "${terraform.workspace}_datomic_transactor_dynamo_db_access_policy"
    policy = jsonencode(local.datomic_transactor_dynamo_db_access_policy)
  }

  inline_policy {
    name   = "${terraform.workspace}_datomic_transactor_cloudwatch_metrics_policy"
    policy = jsonencode(local.datomic_transactor_cloudwatch_metrics_policy)
  }

  inline_policy {
    name   = "${terraform.workspace}_datomic_transactor_memcached_access_policy"
    policy = jsonencode(local.datomic_transactor_memcached_access_policy)
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_transactor_iam_role"
    Environment = terraform.workspace
  }
}

resource "aws_iam_instance_profile" "datomic_transactor_instance_profile" {
  name = "${terraform.workspace}_datomic_transactor_instance_profile"
  path = "/"
  role = aws_iam_role.datomic_transactor_iam_role.name

  tags = {
    Name        = "${terraform.workspace}_datomic_transactor_instance_profile"
    Environment = terraform.workspace
  }
}

resource "aws_launch_configuration" "datomic_transactor_launch_config" {
  name_prefix          = "${terraform.workspace}_datomic_transactor_"
  image_id             = data.aws_ami.datomic_transactor.id
  instance_type        = var.datomic_transactor_instance_type
  iam_instance_profile = aws_iam_instance_profile.datomic_transactor_instance_profile.id
  security_groups = [
    aws_security_group.datomic_transactor_security_group.id
  ]
  user_data                        = local.transactor_provisioning_template
  ebs_optimized                    = true
  key_name                         = var.datomic_transactor_keypair_name
  vpc_classic_link_security_groups = []

  root_block_device {
    volume_type           = var.datomic_transactor_volume_type
    volume_size           = var.datomic_transactor_root_volume_size
    iops                  = var.datomic_transactor_root_iops
    delete_on_termination = true
  }

  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ephemeral_block_device, vpc_classic_link_security_groups]
  }
}

resource "aws_cloudformation_stack" "datomic_transactors_rolling_update_asg" {
  name          = "${terraform.workspace}-datomic-transactors-autoscaling-group"
  template_body = file("${path.module}/cloudformation_stack_asg/auto_scaling_group_template.json")
  parameters = {
    AutoScalingGroupName          = "${terraform.workspace}_datomic_transactors_autoscaling_group"
    AutoScalingGroupDescription   = "${terraform.workspace} Rolling ASG for Datomic Transactors"
    AvailabilityZoneNames         = join(",", var.datomic_transactor_availability_zone_names)
    VPCZoneIdentifier             = join(",", var.datomic_transactor_subnet_ids)
    LaunchConfigurationName       = aws_launch_configuration.datomic_transactor_launch_config.name
    MaximumCapacity               = var.datomic_transactors_max_instance_count
    DesiredCapacity               = var.datomic_transactors_desired_instance_count
    MinimumCapacity               = var.datomic_transactors_min_instance_count
    MinInstancesInService         = "1"
    MaxBatchSize                  = "1"
    PauseTime                     = "180"
    HealthCheckType               = "EC2"
    HealthCheckGracePeriod        = "300"
    MinSuccessfulInstancesPercent = "100"
    UpdatePauseTime               = "120"
    Environment                   = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${terraform.workspace}_datomic_transactors_cfs_rolling_update_asg"
    Environment = terraform.workspace
  }

  depends_on = [aws_launch_configuration.datomic_transactor_launch_config]
}

resource "aws_iam_policy" "datomic_peer_access_policy" {
  name        = "${terraform.workspace}_datomic_peer_access_policy"
  description = "Managed IAM policy to configure Datomic peer access to Datomic infrastructure for env: ${terraform.workspace}"
  policy      = jsonencode(local.datomic_peer_access_policy)

  tags = {
    Name        = "${terraform.workspace}_datomic_peer_access_policy"
    Environment = terraform.workspace
  }
}

resource "aws_iam_policy_attachment" "datomic_peer_access_policy_attachment" {
  name       = "${terraform.workspace}_datomic_peer_access_policy"
  roles      = [var.datomic_peer_iam_role_name]
  policy_arn = aws_iam_policy.datomic_peer_access_policy.arn
}
