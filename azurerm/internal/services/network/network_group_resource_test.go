package network_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/v2/terraform"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/network/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type NetworkGroupResource struct{}

func TestAccNetworkGroup_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
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

func TestAccNetworkGroup_updateGroupMembers(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_group", "test")
	r := NetworkGroupResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.updateGroupMembers(data),
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

resource "azurerm_resource_group" "test" {
  name     = "acctest-network-%d"
  location = "%s"
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsads%s"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_service_endpoint_policy" "test" {
  name                = "acctest-nsep-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_network_virtual_network" "test" {
  name                = "acctest-nvn-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomString, data.RandomInteger, data.RandomInteger)
}

func (r NetworkGroupResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_group" "test" {
  name                 = "acctest-ng-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, template, data.RandomInteger)
}

func (r NetworkGroupResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_group" "import" {
  name                 = azurerm_network_group.test.name
  resource_group_name  = azurerm_network_group.test.resource_group_name
  network_manager_name = azurerm_network_group.test.network_manager_name
}
`, config)
}

func (r NetworkGroupResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_group" "test" {
  name                   = "acctest-ng-%d"
  resource_group_name    = azurerm_resource_group.test.name
  network_manager_name   = azurerm_network_manager.test.name
  conditional_membership = ""
  description            = "A sample group"
  display_name           = "My Network Group"
  group_members {
    resource_id = azurerm_network_virtual_network.test.id
  }
  member_type = "VirtualNetwork"
}
`, template, data.RandomInteger)
}

func (r NetworkGroupResource) updateGroupMembers(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_group" "test" {
  name                   = "acctest-ng-%d"
  resource_group_name    = azurerm_resource_group.test.name
  network_manager_name   = azurerm_network_manager.test.name
  conditional_membership = ""
  description            = "A sample group"
  display_name           = "My Network Group"
  group_members {
    resource_id = azurerm_network_virtual_network.test.id
  }
  member_type = "VirtualNetwork"
}
`, template, data.RandomInteger)
}
