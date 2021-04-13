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

type NetworkAdminRuleResource struct{}

func TestAccNetworkAdminRule_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
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

func TestAccNetworkAdminRule_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
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

func TestAccNetworkAdminRule_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
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

func TestAccNetworkAdminRule_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
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

func TestAccNetworkAdminRule_updateAppliesToGroups(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
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

func TestAccNetworkAdminRule_updateDestination(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.updateDestination(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccNetworkAdminRule_updateSource(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_admin_rule", "test")
	r := NetworkAdminRuleResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.updateSource(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func (r NetworkAdminRuleResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkAdminRuleID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.AdminRuleClient.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.ConfigurationName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network AdminRule %q (Resource Group %q / networkManagerName %q / configurationName %q): %+v", id.Name, id.ResourceGroup, id.NetworkManagerName, id.ConfigurationName, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkAdminRuleResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-network-%d"
  location = "%s"
}

resource "azurerm_network_manager" "test" {
  name = "acctest-nm-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsads%s"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_service_endpoint_policy" "test" {
  name = "acctest-nsep-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}

resource "azurerm_network_virtual_network" "test" {
  name = "acctest-nvn-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}

resource "azurerm_network_group" "test" {
  name = "acctest-ng-%d"
  resource_group_name = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}

resource "azurerm_network_security_configuration" "test" {
  name = "acctest-nsc-%d"
  resource_group_name = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomString, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r NetworkAdminRuleResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "test" {
  name = "acctest-nar-%d"
  resource_group_name = azurerm_resource_group.test.name
  configuration_name = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, template, data.RandomInteger)
}

func (r NetworkAdminRuleResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "import" {
  name = azurerm_network_admin_rule.test.name
  resource_group_name = azurerm_network_admin_rule.test.resource_group_name
  configuration_name = azurerm_network_admin_rule.test.configuration_name
  network_manager_name = azurerm_network_admin_rule.test.network_manager_name
}
`, config)
}

func (r NetworkAdminRuleResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "test" {
  name = "acctest-nar-%d"
  resource_group_name = azurerm_resource_group.test.name
  configuration_name = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  access = "Deny"
  applies_to_groups {
    network_group_id = azurerm_network_group.test.id
  }
  description = "This is Sample Admin Rule"
  destination {
    address_prefix = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction = "Inbound"
  display_name = ""
  priority = 1
  protocol = "Tcp"
  source {
    address_prefix = "Internet"
    address_prefix_type = "ServiceTag"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}

func (r NetworkAdminRuleResource) updateAppliesToGroups(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "test" {
  name = "acctest-nar-%d"
  resource_group_name = azurerm_resource_group.test.name
  configuration_name = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  access = "Deny"
  applies_to_groups {
    network_group_id = azurerm_network_group.test.id
  }
  description = "This is Sample Admin Rule"
  destination {
    address_prefix = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction = "Inbound"
  display_name = ""
  priority = 1
  protocol = "Tcp"
  source {
    address_prefix = "Internet"
    address_prefix_type = "ServiceTag"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}

func (r NetworkAdminRuleResource) updateDestination(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "test" {
  name = "acctest-nar-%d"
  resource_group_name = azurerm_resource_group.test.name
  configuration_name = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  access = "Deny"
  applies_to_groups {
    network_group_id = azurerm_network_group.test.id
  }
  description = "This is Sample Admin Rule"
  destination {
    address_prefix = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction = "Inbound"
  display_name = ""
  priority = 1
  protocol = "Tcp"
  source {
    address_prefix = "Internet"
    address_prefix_type = "ServiceTag"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}

func (r NetworkAdminRuleResource) updateSource(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_admin_rule" "test" {
  name = "acctest-nar-%d"
  resource_group_name = azurerm_resource_group.test.name
  configuration_name = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  access = "Deny"
  applies_to_groups {
    network_group_id = azurerm_network_group.test.id
  }
  description = "This is Sample Admin Rule"
  destination {
    address_prefix = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction = "Inbound"
  display_name = ""
  priority = 1
  protocol = "Tcp"
  source {
    address_prefix = "Internet"
    address_prefix_type = "ServiceTag"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}
