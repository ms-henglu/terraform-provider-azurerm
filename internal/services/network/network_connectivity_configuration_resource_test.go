package network_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/v2/terraform"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/check"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/network/parse"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

type NetworkConnectivityConfigurationResource struct{}

func TestAccNetworkConnectivityConfiguration_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceSequentialTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccNetworkConnectivityConfiguration_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceSequentialTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func TestAccNetworkConnectivityConfiguration_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceSequentialTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccNetworkConnectivityConfiguration_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceSequentialTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func (r NetworkConnectivityConfigurationResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkConnectivityConfigurationID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.ConnectivityConfigurationClient.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.ConnectivityConfigurationName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network ConnectivityConfiguration (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkConnectivityConfigurationResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-network-%d"
  location = "%s"
}

resource "azurerm_network_manager" "test" {
  name                           = "acctest-nm-%d"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = "Jio India Central"
  network_manager_scope_accesses = ["Connectivity"]
  network_manager_scopes {
    subscriptions = [data.azurerm_subscription.current.id]
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-nvn-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_group" "test" {
  name               = "acctest-ng-%d"
  network_manager_id = azurerm_network_manager.test.id

  conditional_membership = "{ \"allOf\": [ { \"field\": \"Name\", \"contains\": \"Blue\" } ] }"
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r NetworkConnectivityConfigurationResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_connectivity_configuration" "test" {
  name               = "acctest-ncc-%d"
  network_manager_id = azurerm_network_manager.test.id
  applies_to_groups {
    group_connectivity = "None"
    is_global          = false
    network_group_id   = azurerm_network_group.test.id
    use_hub_gateway    = true
  }
  connectivity_topology = "Mesh"
}
`, template, data.RandomInteger)
}

func (r NetworkConnectivityConfigurationResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s
resource "azurerm_network_connectivity_configuration" "import" {
  name               = azurerm_network_connectivity_configuration.test.name
  network_manager_id = azurerm_network_connectivity_configuration.test.network_manager_id
}
`, config)
}

func (r NetworkConnectivityConfigurationResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_network_connectivity_configuration" "test" {
  name               = "acctest-ncc-%d"
  network_manager_id = azurerm_network_manager.test.id
  applies_to_groups {
    group_connectivity = "None"
    is_global          = false
    network_group_id   = azurerm_network_group.test.id
    use_hub_gateway    = true
  }
  connectivity_topology   = "HubAndSpoke"
  delete_existing_peering = true
  description             = "Sample Configuration"
  display_name            = "myTestConnectivityConfig"
  hub_id                  = azurerm_virtual_network.test.id
  is_global               = true
}
`, template, data.RandomInteger)
}
