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

type NetworkUserRuleResource struct{}

func TestAccNetworkUserRule_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func TestAccNetworkUserRule_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func TestAccNetworkUserRule_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func TestAccNetworkUserRule_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func TestAccNetworkUserRule_updateDestination(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func TestAccNetworkUserRule_updateSource(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_user_rule", "test")
	r := NetworkUserRuleResource{}
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

func (r NetworkUserRuleResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkUserRuleID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.UserRuleClient.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network UserRule (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkUserRuleResource) template(data acceptance.TestData) string {
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

resource "azurerm_network_group" "test" {
  name                 = "acctest-ng-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}

resource "azurerm_network_security_configuration" "test" {
  name                 = "acctest-nsc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomString, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r NetworkUserRuleResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_user_rule" "test" {
  name                 = "acctest-nur-%d"
  resource_group_name  = azurerm_resource_group.test.name
  configuration_name   = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, template, data.RandomInteger)
}

func (r NetworkUserRuleResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_user_rule" "import" {
  name                 = azurerm_network_user_rule.test.name
  resource_group_name  = azurerm_network_user_rule.test.resource_group_name
  configuration_name   = azurerm_network_user_rule.test.configuration_name
  network_manager_name = azurerm_network_user_rule.test.network_manager_name
}
`, config)
}

func (r NetworkUserRuleResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_user_rule" "test" {
  name                 = "acctest-nur-%d"
  resource_group_name  = azurerm_resource_group.test.name
  configuration_name   = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  description          = "Sample User Rule"
  destination {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction               = "Inbound"
  display_name            = ""
  protocol                = "Tcp"
  source {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}

func (r NetworkUserRuleResource) updateDestination(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_user_rule" "test" {
  name                 = "acctest-nur-%d"
  resource_group_name  = azurerm_resource_group.test.name
  configuration_name   = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  description          = "Sample User Rule"
  destination {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction               = "Inbound"
  display_name            = ""
  protocol                = "Tcp"
  source {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}

func (r NetworkUserRuleResource) updateSource(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_user_rule" "test" {
  name                 = "acctest-nur-%d"
  resource_group_name  = azurerm_resource_group.test.name
  configuration_name   = azurerm_network_security_configuration.test.name
  network_manager_name = azurerm_network_manager.test.name
  description          = "Sample User Rule"
  destination {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  destination_port_ranges = ["22"]
  direction               = "Inbound"
  display_name            = ""
  protocol                = "Tcp"
  source {
    address_prefix      = "*"
    address_prefix_type = "IPPrefix"
  }
  source_port_ranges = ["0-65535"]
}
`, template, data.RandomInteger)
}
