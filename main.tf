# sPECIFy the provider and access details
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region
}

## Network
# Create VPC
module "vpc" {
  source     = "./network/vpc"
  cidr_block = var.cidr_block
}

# Create Subnets
module "subnets" {
  source         = "./network/subnets"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

# Configure Routes
module "route" {
  source              = "./network/route"
  main_route_table_id = module.vpc.main_route_table_id
  gw_id               = module.vpc.gw_id

  subnets = module.subnets.subnets
}

module "sec_group_rds" {
  source         = "./network/sec_group"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "rds" {
  source = "./rds"

  subnets = module.subnets.subnets

  sec_grp_rds       = module.sec_group_rds.sec_grp_rds
  identifier        = var.identifier
  storage_type      = var.storage_type
  allocated_storage = var.allocated_storage
  db_engine         = var.db_engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "s3" {
  source = "./s3"
  #bucket name should be unique
  bucket_name     = var.bucket_name
  sqs_bucket_name = var.sqs_bucket_name
}

module "sqs" {
  source         = "./sqs"
  queue_name     = var.queue_name
  sqs_bucket_id  = module.s3.sqs_bucket_id
  sqs_bucket_arn = module.s3.sqs_bucket_arn
}

module "report_lambda" {
  source     = "./lambda"
  aws_region = var.aws_region
}

module "connection_string_ssm" {
  source    = "./ssm"
  ssm_name  = "/LandCheck/ConnectionStringSSM"
  ssm_value = var.connection_string_ssm
}

module "send_grid_api_key_ssm" {
  source    = "./ssm"
  ssm_name  = "/ContentAPI/SendGridApiKeySSM"
  ssm_value = var.send_grid_api_key_ssm
}

module "auth0_client_id" {
  source    = "./ssm"
  ssm_name  = "/Auth0/ClientId"
  ssm_value = var.auth0_client_id
}

module "auth0_client_secret" {
  source    = "./ssm"
  ssm_name  = "/Auth0/ClientSecret"
  ssm_value = var.auth0_client_secret
}

module "jwt_audience" {
  source    = "./ssm"
  ssm_name  = "/Jwt/Audience"
  ssm_value = var.jwt_audience
}

module "aws_access_Id" {
  source    = "./ssm"
  ssm_name  = "/Aws/AccessId"
  ssm_value = var.access_key
}

module "aws_secret_key" {
  source    = "./ssm"
  ssm_name  = "/Aws/SecretKey"
  ssm_value = var.secret_key
}
