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

type NetworkGroupResource struct{}

func TestAccNetworkGroup_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func (r NetworkGroupResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkGroupID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.GroupClient.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network Group (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkGroupResource) template(data acceptance.TestData) string {
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
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger)
}

func (r NetworkGroupResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_network_group" "test" {
  name               = "acctest-ng-%d"
  network_manager_id = azurerm_network_manager.test.id

  conditional_membership = "{ \"allOf\": [ { \"field\": \"Name\", \"contains\": \"Blue\" } ] }"
}
`, template, data.RandomInteger)
}

func (r NetworkGroupResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s
resource "azurerm_network_group" "import" {
  name               = azurerm_network_group.test.name
  network_manager_id = azurerm_network_group.test.network_manager_id

  conditional_membership = "{ \"allOf\": [ { \"field\": \"Name\", \"contains\": \"Blue\" } ] }"
}
`, config)
}

func (r NetworkGroupResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_network_group" "test" {
  name                   = "acctest-ng-%d"
  network_manager_id     = azurerm_network_manager.test.id
  conditional_membership = "{ \"allOf\": [ { \"field\": \"Name\", \"contains\": \"Blue\" } ] }"
  description            = "A sample group"
  display_name           = "My Network Group"
  group_members {
    resource_id = azurerm_virtual_network.test.id
  }
  member_type = "VirtualNetwork"
}
`, template, data.RandomInteger)
}
