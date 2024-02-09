###########################################################
################## tfstate backend ########################
namespace            = "du"
stage                = "test"
name                 = "narwhal-delivery-iac-swf"
terraform_state_file = "account/terraform.tfstate"
bucket_enabled       = true
dynamodb_enabled     = true
