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

type NetworkManagerResource struct{}

func TestAccNetworkManager_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_manager", "test")
	r := NetworkManagerResource{}
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

func TestAccNetworkManager_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_manager", "test")
	r := NetworkManagerResource{}
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

func TestAccNetworkManager_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_manager", "test")
	r := NetworkManagerResource{}
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

func TestAccNetworkManager_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_manager", "test")
	r := NetworkManagerResource{}
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

func (r NetworkManagerResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkManagerID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.ManagerClient.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network Manager (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkManagerResource) template(data acceptance.TestData) string {
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
`, data.RandomInteger, data.Locations.Primary)
}

func (r NetworkManagerResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_manager" "test" {
  name                           = "acctest-nm-%d"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  network_manager_scope_accesses = ["Connectivity"]
  network_manager_scopes {
    subscriptions = [data.azurerm_subscription.current.id]
  }
}
`, template, data.RandomInteger)
}

func (r NetworkManagerResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_manager" "import" {
  name                           = azurerm_network_manager.test.name
  resource_group_name            = azurerm_network_manager.test.resource_group_name
  location                       = azurerm_network_manager.test.location
  network_manager_scope_accesses = ["Connectivity"]
  network_manager_scopes {
    subscriptions = [data.azurerm_subscription.current.id]
  }
}
`, config)
}

func (r NetworkManagerResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_manager" "test" {
  name                           = "acctest-nm-%d"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  description                    = "My Test Network Manager"
  display_name                   = "TestNetworkManager"
  network_manager_scope_accesses = ["Connectivity"]
  network_manager_scopes {
    subscriptions = [data.azurerm_subscription.current.id]
  }

  tags = {
    env = "Test"
  }
}
`, template, data.RandomInteger)
}
