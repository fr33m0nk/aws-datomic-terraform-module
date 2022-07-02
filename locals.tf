locals {
  datomic_transactor_assume_iam_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Sid = ""
      }
    ]
  }

  datomic_transactor_s3_logs_access_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.datomic_transactor_logs.arn,
          "${aws_s3_bucket.datomic_transactor_logs.arn}/*"
        ]
      }
    ]
  }

  datomic_transactor_dynamo_db_access_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.datomic_dynamo_db_table.arn
        ]
      }
    ]
  }

  datomic_transactor_cloudwatch_metrics_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:PutMetricDataBatch"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
        }
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  }

  datomic_transactor_memcached_access_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECAllowSpecific"
        Effect   = "Allow"
        Action   = ["elasticache:*"]
        Resource = aws_elasticache_cluster.datomic_memcached_cluster.arn
      }
    ]
  }

  datomic_peer_dynamo_db_access_statement = {
    Action = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    Effect = "Allow"
    Resource = [
      aws_dynamodb_table.datomic_dynamo_db_table.arn
    ]
  }

  datomic_peer_cloudwatch_log_access_statement = {
    Effect = "Allow"
    Action = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    Resource = ["arn:aws:logs:*:*:*"]
  }

  datomic_peer_s3_logs_access_statement = {
    Action = [
      "s3:*"
    ]
    Effect = "Allow"
    Resource = [
      aws_s3_bucket.datomic_transactor_logs.arn,
      "${aws_s3_bucket.datomic_transactor_logs.arn}/*"
    ]
  }

  datomic_peer_memcached_access_statement = {
    Sid      = "ECAllowSpecific"
    Effect   = "Allow"
    Action   = ["elasticache:*"]
    Resource = aws_elasticache_cluster.datomic_memcached_cluster.arn
  }

  datomic_peer_access_policy = {
    Version = "2012-10-17"
    Statement = [
      local.datomic_peer_dynamo_db_access_statement,
      local.datomic_peer_cloudwatch_log_access_statement,
      local.datomic_peer_memcached_access_statement,
      local.datomic_peer_s3_logs_access_statement
    ]
  }

  transactor_provisioning_template = templatefile("./scripts/run_transactor.sh", {
    distro_user             = var.datomic_transactor_ami_user
    log_level               = var.datomic_transactor_log_level
    jvm_xmx                 = var.datomic_transactor_jvm_xmx
    jvm_xms                 = var.datomic_transactor_jvm_xms
    java_opts               = var.datomic_transactor_java_opts
    protocol                = "ddb"
    datomic_license         = var.datomic_license
    aws_dynamodb_table      = aws_dynamodb_table.datomic_dynamo_db_table.name
    aws_dynamodb_region     = var.aws_region
    transactor_role         = aws_iam_role.datomic_transactor_iam_role.name
    peer_role               = var.datomic_peer_iam_role_name
    memory_index_max        = var.datomic_transactor_memory_index_max
    memory_index_threshold  = var.datomic_transactor_memory_index_threshold
    object_cache_max        = var.datomic_transactor_object_cache_max
    s3_log_bucket_id        = aws_s3_bucket.datomic_transactor_logs.id
    memcached_uri           = aws_elasticache_cluster.datomic_memcached_cluster.configuration_endpoint
    cloudwatch_region       = var.aws_region
    cloudwatch_dimension    = "${terraform.workspace}_datomic_transactors"
    write_concurrency       = var.datomic_transactor_write_concurrency
    read_concurrency        = var.datomic_transactor_read_concurrency
    enable_datadog          = var.datomic_transactor_enable_datadog
    metric_callback_library = var.datomic_transactor_metric_callback_library
  })
}
