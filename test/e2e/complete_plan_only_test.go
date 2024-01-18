package e2e_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestCompletePlanOnly(t *testing.T) {
	t.Parallel()
	tempFolder := teststructure.CopyTerraformFolderToTemp(t, "../..", "terraform")
	terraformOptionsPlan := &terraform.Options{
		TerraformDir: tempFolder,
		Upgrade:      false,
		VarFiles: []string{
			"tfvars/base/s.tfvars",
			"tfvars/dev/s.tfvars",
		},
		// Set any overrides for variables you would like to validate
		Vars: map[string]interface{}{
			"keycloak_enabled": false,
		},
		SetVarsAfterVarFiles: true,
	}
	teststructure.RunTestStage(t, "SETUP", func() {
		terraform.Init(t, terraformOptionsPlan)
		terraform.Plan(t, terraformOptionsPlan)
	})
}
