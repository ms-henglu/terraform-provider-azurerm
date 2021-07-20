package machinelearning_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/machinelearning/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type MachineLearningDataLakeAnalyticsResource struct{}

var dataLakeAnalyticsIgnores = []string{
	"databricksIgnores", // bug, not returned
}

func TestAccMachineLearningDataLakeAnalytics_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_data_lake_analytics", "test")
	r := MachineLearningDataLakeAnalyticsResource{}

	data.ResourceSequentialTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
	})
}

func TestAccMachineLearningDataLakeAnalytics_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_data_lake_analytics", "test")
	r := MachineLearningDataLakeAnalyticsResource{}

	data.ResourceSequentialTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.#").HasValue("1"),
				check.That(data.ResourceName).Key("identity.0.type").HasValue("SystemAssigned"),
				check.That(data.ResourceName).Key("identity.0.principal_id").Exists(),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
	})
}

func TestAccMachineLearningDataLakeAnalytics_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_data_lake_analytics", "test")
	r := MachineLearningDataLakeAnalyticsResource{}

	data.ResourceSequentialTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
	})
}

func TestAccMachineLearningDataLakeAnalytics_identity(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_data_lake_analytics", "test")
	r := MachineLearningDataLakeAnalyticsResource{}

	data.ResourceSequentialTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
		{
			Config: r.identitySystemAssignedUserAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.0.principal_id").MatchesRegex(validate.UUIDRegExp),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
		{
			Config: r.identityUserAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
		{
			Config: r.identitySystemAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.0.principal_id").MatchesRegex(validate.UUIDRegExp),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(dataLakeAnalyticsIgnores...),
	})
}

func TestAccMachineLearningDataLakeAnalytics_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_data_lake_analytics", "test")
	r := MachineLearningDataLakeAnalyticsResource{}

	data.ResourceSequentialTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func (r MachineLearningDataLakeAnalyticsResource) Exists(ctx context.Context, client *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	computeClusterClient := client.MachineLearning.MachineLearningComputeClient
	id, err := parse.ComputeID(state.ID)

	if err != nil {
		return nil, err
	}

	computeResource, err := computeClusterClient.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(computeResource.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Machine Learning Compute %q: %+v", state.ID, err)
	}
	return utils.Bool(computeResource.Properties != nil), nil
}

func (r MachineLearningDataLakeAnalyticsResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_machine_learning_data_lake_analytics" "test" {
  name                           = "acctest%d"
  location                       = azurerm_resource_group.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_workspace.test.id
  data_lake_analytics_account_id = azurerm_data_lake_analytics_account.test.id
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningDataLakeAnalyticsResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_machine_learning_data_lake_analytics" "test" {
  name                           = "acctest%d"
  location                       = azurerm_resource_group.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_workspace.test.id
  data_lake_analytics_account_id = azurerm_data_lake_analytics_account.test.id
  identity {
    type = "SystemAssigned"
  }
  description = "test"
  tags = {
    "Key" = "value"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningDataLakeAnalyticsResource) requiresImport(data acceptance.TestData) string {
	template := r.basic(data)
	return fmt.Sprintf(`
%s
resource "azurerm_machine_learning_data_lake_analytics" "import" {
  name                           = azurerm_machine_learning_data_lake_analytics.test.name
  location                       = azurerm_machine_learning_data_lake_analytics.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_data_lake_analytics.test.machine_learning_workspace_id
  data_lake_analytics_account_id = azurerm_machine_learning_data_lake_analytics.test.data_lake_analytics_account_id
}

`, template)
}

func (r MachineLearningDataLakeAnalyticsResource) identitySystemAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_machine_learning_data_lake_analytics" "test" {
  name                           = "acctest%d"
  location                       = azurerm_resource_group.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_workspace.test.id
  data_lake_analytics_account_id = azurerm_data_lake_analytics_account.test.id
  identity {
    type = "SystemAssigned"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningDataLakeAnalyticsResource) identityUserAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_machine_learning_data_lake_analytics" "test" {
  name                           = "acctest%d"
  location                       = azurerm_resource_group.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_workspace.test.id
  data_lake_analytics_account_id = azurerm_data_lake_analytics_account.test.id
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
`, template, data.RandomInteger, data.RandomIntOfLength(8))
}

func (r MachineLearningDataLakeAnalyticsResource) identitySystemAssignedUserAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_machine_learning_data_lake_analytics" "test" {
  name                           = "acctest%d"
  location                       = azurerm_resource_group.test.location
  machine_learning_workspace_id  = azurerm_machine_learning_workspace.test.id
  data_lake_analytics_account_id = azurerm_data_lake_analytics_account.test.id
  identity {
    type = "SystemAssigned,UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
`, template, data.RandomInteger, data.RandomIntOfLength(8))
}

func (r MachineLearningDataLakeAnalyticsResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-%d"
  location = "%s"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvault%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa%d"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_lake_store" "test" {
  name                = "akestore%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_analytics_account" "test" {
  name                = "taccount%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  default_store_account_name = azurerm_data_lake_store.test.name
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW%d"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}
`, data.RandomInteger, data.Locations.Primary,
		data.RandomIntOfLength(8), data.RandomIntOfLength(8), data.RandomIntOfLength(8),
		data.RandomIntOfLength(8), data.RandomIntOfLength(8), data.RandomInteger)
}
