terraform {
  required_providers {
    netapp-cloudmanager = {
      source  = "netapp/netapp-cloudmanager"
      version = "21.9.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.58.0"
    }
  }
}

# Define Cloud Manager variables
provider "netapp-cloudmanager" {
  refresh_token = var.refresh_token
}

# Define AWS as our provider
provider "aws" {
  region = local.aws.region
  /* Set credentials in ~/.aws/credentials
  [default]
  aws_access_key_id = *****************
  aws_secret_access_key = **********************************
  */
}

locals {
  aws = {
    vpc_id = "VPC_ID"
    subnet_id = "SUBNET_ID"
    key_name = "EC2_KEY_NAME"
    region = "us-east-1"
  }
  netapp = {
    account_id = "NETAPP_ACCOUNT_ID"
    company_name = "NetApp"
  }
}

####### AWS #######

# AWS SG
resource "aws_security_group" "allow_all_internal_sg" {
  name        = "allow_all_internal"
  description = "Allow ALL internal traffic"
  vpc_id      = local.aws.vpc_id

  ingress {
      description      = "All from all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = var.src_ip_ranges
    }

  egress {
      description      = "All to all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_all"
  }
}

# Create OCCM Role
resource "aws_iam_role" "occm_role" {
  name = "occm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Create OCCM policy
resource "aws_iam_policy" "occm_policy" {
  name = "occm-policy"
  policy = file("./aws_occm_policy.json")

}

# Create role policy attachment
resource "aws_iam_role_policy_attachment" "occm_role_attach" {
  role = aws_iam_role.occm_role.name
  policy_arn = aws_iam_policy.occm_policy.arn
}

# Create occm instance profile
resource "aws_iam_instance_profile" "occm_instance_profile" {
  name = "occm-profile"
  role = aws_iam_role.occm_role.name
}

##### NTAP #####

# Build AWS Cloud Manager
resource "netapp-cloudmanager_connector_aws" "occm_aws" {
  depends_on = [
    aws_security_group.allow_all_internal_sg,
    aws_iam_role.occm_role,
    aws_iam_policy.occm_policy,
    aws_iam_role_policy_attachment.occm_role_attach,
    aws_iam_instance_profile.occm_instance_profile
  ]

  name = "InsightConnectorAWS"
  region = local.aws.region
  key_name = local.aws.key_name
  company = local.netapp.company_name
  instance_type = "t3.xlarge"
  subnet_id = local.aws.subnet_id
  security_group_id = aws_security_group.allow_all_internal_sg.id
  iam_instance_profile_name = aws_iam_instance_profile.occm_instance_profile.name
  account_id = local.netapp.account_id
  associate_public_ip_address = true
}

# Build AWS CVO src
resource "netapp-cloudmanager_cvo_aws" "cvo_aws_us_east_1_src" {
  depends_on = [netapp-cloudmanager_connector_aws.occm_aws]

  name = "InsightCVOAWSsrc"
  region = "us-east-1"
  subnet_id = local.aws.subnet_id
  vpc_id = local.aws.vpc_id
  svm_password = "Netapp1!"
  client_id = netapp-cloudmanager_connector_aws.occm_aws.client_id
  writing_speed_state = "NORMAL"
  license_type = "cot-standard-paygo"
  instance_type = "m5.2xlarge"
}

# Build AWS CVO dst
resource "netapp-cloudmanager_cvo_aws" "cvo_aws_us_east_1_dst" {
  depends_on = [netapp-cloudmanager_connector_aws.occm_aws]

  name = "InsightCVOAWSdst"
  region = "us-east-1"
  subnet_id = local.aws.subnet_id
  vpc_id = local.aws.vpc_id
  svm_password = "Netapp1!"
  client_id = netapp-cloudmanager_connector_aws.occm_aws.client_id
  writing_speed_state = "NORMAL"
  license_type = "cot-standard-paygo"
  instance_type = "m5.2xlarge"
}
