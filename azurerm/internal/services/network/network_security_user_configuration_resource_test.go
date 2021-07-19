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

type NetworkSecurityUserConfigurationResource struct{}

func TestAccNetworkSecurityUserConfiguration_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_security_user_configuration", "test")
	r := NetworkSecurityUserConfigurationResource{}
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

func TestAccNetworkSecurityUserConfiguration_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_security_user_configuration", "test")
	r := NetworkSecurityUserConfigurationResource{}
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

func TestAccNetworkSecurityUserConfiguration_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_security_user_configuration", "test")
	r := NetworkSecurityUserConfigurationResource{}
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

func TestAccNetworkSecurityUserConfiguration_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_network_security_user_configuration", "test")
	r := NetworkSecurityUserConfigurationResource{}
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

func (r NetworkSecurityUserConfigurationResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.NetworkSecurityUserConfigurationID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Network.SecurityUserConfigurationClient.Get(ctx, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Network SecurityUserConfiguration (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r NetworkSecurityUserConfigurationResource) template(data acceptance.TestData) string {
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
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomString, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r NetworkSecurityUserConfigurationResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_security_user_configuration" "test" {
  name                 = "acctest-nsc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
}
`, template, data.RandomInteger)
}

func (r NetworkSecurityUserConfigurationResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_security_user_configuration" "import" {
  name                 = azurerm_network_security_configuration.test.name
  resource_group_name  = azurerm_network_security_configuration.test.resource_group_name
  network_manager_name = azurerm_network_security_configuration.test.network_manager_name
}
`, config)
}

func (r NetworkSecurityUserConfigurationResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_network_security_user_configuration" "test" {
  name                 = "acctest-nsc-%d"
  resource_group_name  = azurerm_resource_group.test.name
  network_manager_name = azurerm_network_manager.test.name
  delete_existing_nsgs = true
  description          = "A sample policy"
  display_name         = ""
  security_type        = "UserPolicy"
}
`, template, data.RandomInteger)
}
