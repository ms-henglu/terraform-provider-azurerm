package network_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/network/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type NetworkConnectivityConfigurationResource struct{}

func TestAccNetworkConnectivityConfiguration_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceTest(t, r, []resource.TestStep{
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
	data.ResourceTest(t, r, []resource.TestStep{
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
	data.ResourceTest(t, r, []resource.TestStep{
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
	data.ResourceTest(t, r, []resource.TestStep{
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

func TestAccNetworkConnectivityConfiguration_updateAppliesToGroups(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_connectivity_configuration", "test")
	r := NetworkConnectivityConfigurationResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.updateAppliesToGroups(data),
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

resource "azurerm_resource_group" "test" {
  name     = "acctest-network-%d"
  location = "%s"
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger)
}

func (r NetworkConnectivityConfigurationResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_connectivity_configuration" "test" {
  name                 = "acctest-ncc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, template, data.RandomInteger)
}

func (r NetworkConnectivityConfigurationResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_connectivity_configuration" "import" {
  name                 = azurerm_network_connectivity_configuration.test.name
  resource_group_name  = azurerm_network_connectivity_configuration.test.resource_group_name
  network_manager_name = azurerm_network_connectivity_configuration.test.network_manager_name
}
`, config)
}

func (r NetworkConnectivityConfigurationResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_connectivity_configuration" "test" {
  name                 = "acctest-ncc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
  applies_to_groups {
    group_connectivity = "Transitive"
    is_global          = false
    network_group_id   = "subscriptions/subscriptionA/resourceGroups/myResourceGroup/providers/Microsoft.Network/networkManagers/testNetworkManager/networkManagerGroups/group1"
    use_hub_gateway    = true
  }
  connectivity_topology   = "HubAndSpokeTopology"
  delete_existing_peering = true
  description             = "Sample Configuration"
  display_name            = "myTestConnectivityConfig"
  hub_id                  = "subscriptions/subscriptionA/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myTestConnectivityConfig"
  is_global               = true
}
`, template, data.RandomInteger)
}

func (r NetworkConnectivityConfigurationResource) updateAppliesToGroups(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_connectivity_configuration" "test" {
  name                 = "acctest-ncc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
  applies_to_groups {
    group_connectivity = "Transitive"
    is_global          = false
    network_group_id   = "subscriptions/subscriptionA/resourceGroups/myResourceGroup/providers/Microsoft.Network/networkManagers/testNetworkManager/networkManagerGroups/group1"
    use_hub_gateway    = true
  }
  connectivity_topology   = "HubAndSpokeTopology"
  delete_existing_peering = true
  description             = "Sample Configuration"
  display_name            = "myTestConnectivityConfig"
  hub_id                  = "subscriptions/subscriptionA/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myTestConnectivityConfig"
  is_global               = true
}
`, template, data.RandomInteger)
}
