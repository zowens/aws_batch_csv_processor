# AWS Batch CSV Processor

Example project demonstrating an AWS Batch infrastructure for processing CSV files from S3.

Builders often turn to AWS Lambda as an S3 trigger to process files as they are uploaded. While this may work for some
use cases, Lambdas have the following limitations that may not fit this use case:

* 5 minute maximum
* Limited retries
* Low memory limit
* Limited instance-based storage

AWS Batch is a container-based solution that alleviates some of these concerns. EC2 spot can be used to lower the cost of
the solution.

## Infrastructure
* *AWS CodeCommit repository* for the code repository
* *AWS EC2 Container Registry* Docker image registry
* *AWS CodeBuild* will build the Docker image and push to the ECR repository
* *AWS Batch Compute Cluster* will use a spot fleet at 25% of the on-demand price
* *AWS Batch Job* will run a python script to process the CSV in a streaming fashion 

Terraform is used to describe the infrastructure.

## Setup

* Create a file for the terraform variables (deploy/terraform.tfvars)

```
region = "us-west-2"
vpc_id = "vpc-XXXXXXX"
security_group_ids = [
    "sg-XXXXXXXX"
]
```

* Use Terraform to setup the infrastructure

```bash
cd deploy
terraform apply
```

* Push the code to your newly created CodeCommit repository

```bash
git remote add codecommit <SSH_URL>
git push codecommit master
```

* Submit a build

```bash
aws codebuild start-build --project-name aws_batch_csv_processor
```

* Once the build completes, a Batch job can be submitted

```bash
aws batch submit-job --job-name "first_run" --job-queue "batch_job_queue" --job-definition batch_csv_processor:1
```

* Once the job is complete, the logs will show up in CloudWatch logs

## Customization

The CSV processor in the repository is quite simple (it just counts the columns and rows). But you
can customize the script to do whatever you need to with the CSV!

The code is located in `aws_batch_csv_processor/__main__.py`. Most of the code is dedicated to reading
the CSV file from S3 by streaming the contents.

The parameters to the batch job are the S3 bucket and key for the file:
* _bucket_ is the S3 bucket parameter
* _path_ is the path to the S3 object to read

By default, the job will read the [IRS 990 public dataset](https://aws.amazon.com/public-datasets/irs-990/) for 2017.
