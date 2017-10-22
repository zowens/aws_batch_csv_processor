resource "aws_batch_compute_environment" "compute" {
  compute_environment_name = "spot_m_class"
  compute_resources {
    instance_role = "${aws_iam_instance_profile.ecs_instance_role.arn}"
    instance_type = ["m3", "m4"]
    max_vcpus = 16
    min_vcpus = 0
    security_group_ids = ["${var.security_group_ids}"]
    subnets = ["${data.aws_subnet_ids.subnets.ids}"]

    # Spot-related configuration
    type = "SPOT"
    bid_percentage = 25
    spot_iam_fleet_role = "${aws_iam_role.spot_fleet_role.arn}"
  }
  service_role = "${aws_iam_role.aws_batch_service_role.arn}"
  type = "MANAGED"
  depends_on = ["aws_iam_role_policy_attachment.aws_batch_service_role"]
}

# AWS Batch Queue
resource "aws_batch_job_queue" "job_queue" {
  name = "batch_job_queue"
  state = "ENABLED"
  priority = 1
  compute_environments = ["${aws_batch_compute_environment.compute.arn}"]
  depends_on = [
    "aws_batch_compute_environment.compute"
  ]
}

# AWS Batch Job
resource "aws_iam_role" "task_role" {
  name = "aws_batch_task_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
        }
    }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "aws_batch_task_role_s3" {
  # allow the task to read from S3
  role       = "${aws_iam_role.task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


resource "aws_batch_job_definition" "csv_processor" {
    name = "batch_csv_processor"
    type = "container"
    retry_strategy {
        attempts = 5
    }
    parameters = {
        "bucket" = "irs-form-990"
        "path" = "index_2017.csv"
    }
    container_properties = <<EOF
{
    "command": ["Ref::bucket", "Ref::path"],
    "image": "${aws_ecr_repository.docker_repo.repository_url}:${var.image_tag}",
    "memory": 1024,
    "vcpus": 1,
    "ulimits": [
      {
        "hardLimit": 1024,
        "name": "nofile",
        "softLimit": 1024
      }
    ],
    "jobRoleArn": "${aws_iam_role.task_role.arn}"
}
EOF
}
