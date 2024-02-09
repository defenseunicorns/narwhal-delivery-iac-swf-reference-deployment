terraform {

  required_version = ">= ${terraform_version}"

  backend "s3" {
    region  = "${region}"
    bucket  = "${namespace}-${stage}-${name}-state"
    key     = "${terraform_state_file}"
    dynamodb_table = "${namespace}-${stage}-${name}-state-lock"
    profile = "${profile}"
    encrypt = "${encrypt}"
    %{~ if role_arn != "" ~}
    assume_role {
      role_arn = "${role_arn}"
    }
    %{~ endif ~}
  }

}
