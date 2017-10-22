# Codebuild-related resources to build and push container
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "codecommit:GitPull",
        "ecr:GetAuthorizationToken",
	    "ecr:BatchCheckLayerAvailability",
		"ecr:GetDownloadUrlForLayer",
		"ecr:GetRepositoryPolicy",
		"ecr:DescribeRepositories",
		"ecr:ListImages",
		"ecr:DescribeImages",
		"ecr:BatchGetImage",
		"ecr:InitiateLayerUpload",
		"ecr:UploadLayerPart",
		"ecr:CompleteLayerUpload",
		"ecr:PutImage"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "build" {
  name = "aws_batch_csv_processor"
  description = "AWS Batch-based CSV processor"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/docker:1.12.1"
    type         = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "IMAGE_REPO_NAME"
      "value" = "${var.image_name}"
    }

    environment_variable {
        "name" = "IMAGE_TAG"
        "value" = "${var.image_tag}"
    }

    environment_variable {
        "name" = "IMAGE_REPOSITORY_URL"
        "value" = "${aws_ecr_repository.docker_repo.repository_url}"

    }
  }

  source {
    type     = "CODECOMMIT"
    location = "${aws_codecommit_repository.code_repo.clone_url_http}"
  }
}
