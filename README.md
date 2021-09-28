Instructions to run code

- Prereqs:
 - AWS Account
 - AWS User/Terraform account with Secret Key & Access Key
 - VPC & Subnet in region you're deploying into (Can be terraformed)
 - NetApp Cloud Central Account & User/Service Account with Account Admin permissions
 - Generate Refresh Token for Cloud Central


- Steps:
 - Download repro from github
 - Replace src_ip_ranges & refresh_token variables in variables.tf file. src_ip_ranges should contain the ip ranges of the clients accessing Cloud Manager locally (Likely VPC ip range)
 - Replace vpc_id, subnet_id, key_name & region in "locals.aws" inside main.tf
 - Replace account_id & company_name in "locals.netapp" inside main.tf
 - Set AWS user/terraform account credentials in ~/.aws/credentials:
 ```
 [default]
 aws_access_key_id = *****************
 aws_secret_access_key = **********************************
 ```
 - Ensure Cloud Manager account has AWS subscription for Cloud Manager associated:
    - Visit: <a href="https://aws.amazon.com/marketplace/pp/prodview-eap6ybxwk5ycg?ref_=unifiedsearch">the AWS marketplace listing</a>
    - Click "Continue to Subscribe"
    - Subscribe and Continue to Configure on Cloud Central
    - Choose Name for subscription and Save to Cloud Manager Account
 - run:
 ```
 terraform init
 terraform plan
 terraform terraform apply
 ```
