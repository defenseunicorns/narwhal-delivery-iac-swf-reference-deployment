###########################################################
################## Global Settings ########################
region = "us-gov-west-1"

tags = {
  Environment = "dev"
  Project     = "du-iac-cicd"
}
name_prefix = "nwl-iac-swf"

###########################################################
################## tfstate backend ########################
namespace            = "du"
stage                = "test"
name                 = "narwhal-delivery-iac-swf"
terraform_state_file = "account/terraform.tfstate"
bucket_enabled       = true
dynamodb_enabled     = true
