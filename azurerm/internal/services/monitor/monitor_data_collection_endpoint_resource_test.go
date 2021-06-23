package monitor_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type MonitorDataCollectionEndpointResource struct {
}

func TestAccMonitorDataCollectionEndpoint_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_endpoint", "test")
	r := MonitorDataCollectionEndpointResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("public_network_access_enabled").HasValue("true"),
				check.That(data.ResourceName).Key("configuration_access_endpoint").Exists(),
				check.That(data.ResourceName).Key("logs_ingestion_endpoint").Exists(),
			),
		},
		data.ImportStep(),
	})
}

func TestAccMonitorDataCollectionEndpoint_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_endpoint", "test")
	r := MonitorDataCollectionEndpointResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		{
			Config:      r.requiresImport(data),
			ExpectError: acceptance.RequiresImportError("azurerm_monitor_data_collection_endpoint"),
		},
	})
}

func TestAccMonitorDataCollectionEndpoint_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_endpoint", "test")
	r := MonitorDataCollectionEndpointResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("public_network_access_enabled").HasValue("false"),
				check.That(data.ResourceName).Key("configuration_access_endpoint").Exists(),
				check.That(data.ResourceName).Key("logs_ingestion_endpoint").Exists(),
			),
		},
		data.ImportStep(),
	})
}

func TestAccMonitorDataCollectionEndpoint_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_endpoint", "test")
	r := MonitorDataCollectionEndpointResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("public_network_access_enabled").HasValue("true"),
				check.That(data.ResourceName).Key("configuration_access_endpoint").Exists(),
				check.That(data.ResourceName).Key("logs_ingestion_endpoint").Exists(),
			),
		},
		data.ImportStep(),
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("public_network_access_enabled").HasValue("false"),
				check.That(data.ResourceName).Key("configuration_access_endpoint").Exists(),
				check.That(data.ResourceName).Key("logs_ingestion_endpoint").Exists(),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("public_network_access_enabled").HasValue("true"),
				check.That(data.ResourceName).Key("configuration_access_endpoint").Exists(),
				check.That(data.ResourceName).Key("logs_ingestion_endpoint").Exists(),
			),
		},
		data.ImportStep(),
	})
}

func (r MonitorDataCollectionEndpointResource) Exists(ctx context.Context, client *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := parse.DataCollectionEndpointID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Monitor.DataCollectionEndpointsClient.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Monitor DataCollectionEndpoint (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r MonitorDataCollectionEndpointResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctest-doe-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger)
}

func (r MonitorDataCollectionEndpointResource) requiresImport(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}
resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctest-doe-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_monitor_data_collection_endpoint" "import" {
  name                = azurerm_monitor_data_collection_endpoint.test.name
  location            = azurerm_monitor_data_collection_endpoint.test.location
  resource_group_name = azurerm_monitor_data_collection_endpoint.test.resource_group_name
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger)
}

func (r MonitorDataCollectionEndpointResource) complete(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctest-doe-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  kind                          = "Windows"
  public_network_access_enabled = false
  description                   = "this is description"

  tags = {
    label1 = "value1"
  }
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger)
}
