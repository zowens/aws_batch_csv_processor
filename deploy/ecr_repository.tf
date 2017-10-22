# Repository for the AWS Batch container image
resource "aws_ecr_repository" "docker_repo" {
  name = "batch_jobs/${var.image_name}"
}
