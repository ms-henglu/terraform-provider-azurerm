package acceptance

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/terraform"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/helpers"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/testclient"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/types"
	"github.com/hashicorp/terraform-provider-azurerm/internal/provider"
)

func (td TestData) DataSourceTest(t *testing.T, steps []TestStep) {
	// DataSources don't need a check destroy - however since this is a wrapper function
	// and not matching the ignore pattern `XXX_data_source_test.go`, this needs to be explicitly opted out

	//lintignore:AT001
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		Steps:    steps,
	}
	td.runAcceptanceTest(t, testCase)
}

func (td TestData) DataSourceTestInSequence(t *testing.T, steps []TestStep) {
	// DataSources don't need a check destroy - however since this is a wrapper function
	// and not matching the ignore pattern `XXX_data_source_test.go`, this needs to be explicitly opted out

	//lintignore:AT001
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		Steps:    steps,
	}

	td.runAcceptanceSequentialTest(t, testCase)
}

func (td TestData) ResourceTest(t *testing.T, testResource types.TestResource, steps []TestStep) {
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		CheckDestroy: func(s *terraform.State) error {
			client, err := testclient.Build()
			if err != nil {
				return fmt.Errorf("building client: %+v", err)
			}
			return helpers.CheckDestroyedFunc(client, testResource, td.ResourceType, td.ResourceName)(s)
		},
		Steps: steps,
	}
	td.runAcceptanceTest(t, testCase)
}

// ResourceTestIgnoreCheckDestroyed skips the check to confirm the resource test has been destroyed.
// This is done because certain resources can't actually be deleted.
func (td TestData) ResourceTestSkipCheckDestroyed(t *testing.T, steps []TestStep) {
	//lintignore:AT001
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		Steps:    steps,
	}
	td.runAcceptanceTest(t, testCase)
}

func (td TestData) ResourceSequentialTestSkipCheckDestroyed(t *testing.T, steps []TestStep) {
	//lintignore:AT001
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		Steps:    steps,
	}
	td.runAcceptanceSequentialTest(t, testCase)
}

func (td TestData) ResourceSequentialTest(t *testing.T, testResource types.TestResource, steps []TestStep) {
	testCase := resource.TestCase{
		PreCheck: func() { PreCheck(t) },
		CheckDestroy: func(s *terraform.State) error {
			client, err := testclient.Build()
			if err != nil {
				return fmt.Errorf("building client: %+v", err)
			}
			return helpers.CheckDestroyedFunc(client, testResource, td.ResourceType, td.ResourceName)(s)
		},
		Steps: steps,
	}

	td.runAcceptanceSequentialTest(t, testCase)
}

func RunTestsInSequence(t *testing.T, tests map[string]map[string]func(t *testing.T)) {
	for group, m := range tests {
		m := m
		t.Run(group, func(t *testing.T) {
			for name, tc := range m {
				tc := tc
				t.Run(name, func(t *testing.T) {
					tc(t)
				})
			}
		})
	}
}

func (td TestData) runAcceptanceTest(t *testing.T, testCase resource.TestCase) {
	testCase.ExternalProviders = td.externalProviders()
	testCase.ProviderFactories = td.providers()
	td.modifyTestCase(&testCase)
	resource.ParallelTest(t, testCase)
}

func (td TestData) runAcceptanceSequentialTest(t *testing.T, testCase resource.TestCase) {
	testCase.ExternalProviders = td.externalProviders()
	testCase.ProviderFactories = td.providers()
	td.modifyTestCase(&testCase)
	resource.Test(t, testCase)
}

func (td TestData) providers() map[string]func() (*schema.Provider, error) {
	return map[string]func() (*schema.Provider, error){
		"azurerm": func() (*schema.Provider, error) { //nolint:unparam
			azurerm := provider.TestAzureProvider()
			return azurerm, nil
		},
		"azurerm-alt": func() (*schema.Provider, error) { //nolint:unparam
			azurerm := provider.TestAzureProvider()
			return azurerm, nil
		},
	}
}

func (td TestData) externalProviders() map[string]resource.ExternalProvider {
	return map[string]resource.ExternalProvider{
		"azuread": {
			VersionConstraint: "=2.8.0",
			Source:            "registry.terraform.io/hashicorp/azuread",
		},
	}
}

func (td TestData) modifyTestCase(testCase *resource.TestCase) {
	providersBackup := testCase.ProviderFactories
	externalProvidersBackup := testCase.ExternalProviders
	testCase.ProviderFactories = nil
	testCase.ExternalProviders = nil

	// add missing import step
	steps := make([]TestStep, 0)
	for i, step := range testCase.Steps {
		steps = append(steps, step)
		if !step.ImportState && step.ExpectError == nil && (i == len(testCase.Steps)-1 || !testCase.Steps[i+1].ImportState) {
			steps = append(steps, TestStep{
				ResourceName:      td.ResourceName,
				ImportState:       true,
				ImportStateVerify: true,
			})
		}
	}

	versionConstraint := ""
	if version := os.Getenv("TF_ACC_PROVIDER_VERSION"); version != "" {
		versionConstraint = fmt.Sprintf("=%s", strings.TrimPrefix(version, "v"))
	}

	for index, step := range steps {
		if step.ImportState {
			steps[index].ProviderFactories = providersBackup
			steps[index].ExternalProviders = externalProvidersBackup
		} else {
			steps[index].ProviderFactories = map[string]func() (*schema.Provider, error){}
			steps[index].ExternalProviders = map[string]resource.ExternalProvider{
				"azuread": {
					VersionConstraint: "=2.8.0",
					Source:            "registry.terraform.io/hashicorp/azuread",
				},
				"azurerm": {
					VersionConstraint: versionConstraint,
					Source:            "registry.terraform.io/hashicorp/azurerm",
				},
			}
		}
	}

	testCase.Steps = steps
}
