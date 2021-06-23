package monitor_test

import (
	"context"
	"fmt"
	computeParse "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/compute/parse"
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type MonitorDataCollectionRuleAssociationResource struct {
}

func TestAccMonitorDataCollectionRuleAssociation_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_rule_association", "test")
	r := MonitorDataCollectionRuleAssociationResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccMonitorDataCollectionRuleAssociation_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_rule_association", "test")
	r := MonitorDataCollectionRuleAssociationResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		{
			Config:      r.requiresImport(data),
			ExpectError: acceptance.RequiresImportError("azurerm_monitor_data_collection_rule_association"),
		},
	})
}

func TestAccMonitorDataCollectionRuleAssociation_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_rule_association", "test")
	r := MonitorDataCollectionRuleAssociationResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccMonitorDataCollectionRuleAssociation_endpoint(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_rule_association", "test")
	r := MonitorDataCollectionRuleAssociationResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.endpoint(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccMonitorDataCollectionRuleAssociation_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_monitor_data_collection_rule_association", "test")
	r := MonitorDataCollectionRuleAssociationResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.endpoint(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func (r MonitorDataCollectionRuleAssociationResource) Exists(ctx context.Context, client *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := parse.DataCollectionRuleAssociationID(state.ID)
	if err != nil {
		return nil, err
	}
	vmId := computeParse.NewVirtualMachineID(id.SubscriptionId, id.ResourceGroup, id.VirtualMachineName)
	resp, err := client.Monitor.DataCollectionRuleAssociationsClient.Get(ctx, vmId.ID(), id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Monitor DataCollectionRuleAssociation (%q): %+v", id, err)
	}
	return utils.Bool(true), nil
}

func (r MonitorDataCollectionRuleAssociationResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctest-dor-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  azure_monitor_metrics_destination {
    name = "acctest-amm-%d"
  }

  windows_event_log_data_source {
    name          = "cloudSecurityTeamEvents"
    streams       = ["Microsoft-WindowsEvent"]
    xpath_queries = ["Security!"]
  }

  data_flows {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["acctest-amm-%d"]
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-%d"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-%d"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctest-ni-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctest-vm-%d"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.test.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_monitor_data_collection_rule_association" "test" {
  name                    = "acctest-dora-%d"
  virtual_machine_id      = azurerm_virtual_machine.test.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.test.id
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r MonitorDataCollectionRuleAssociationResource) requiresImport(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctest-dor-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  azure_monitor_metrics_destination {
    name = "acctest-amm-%d"
  }

  windows_event_log_data_source {
    name          = "cloudSecurityTeamEvents"
    streams       = ["Microsoft-WindowsEvent"]
    xpath_queries = ["Security!"]
  }

  data_flows {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["acctest-amm-%d"]
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-%d"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-%d"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctest-ni-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctest-vm-%d"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.test.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_monitor_data_collection_rule_association" "test" {
  name                    = "acctest-dora-%d"
  virtual_machine_id      = azurerm_virtual_machine.test.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.test.id
}

resource "azurerm_monitor_data_collection_rule_association" "import" {
  name                    = azurerm_monitor_data_collection_rule_association.test.name
  virtual_machine_id      = azurerm_monitor_data_collection_rule_association.test.virtual_machine_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule_association.test.data_collection_rule_id
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r MonitorDataCollectionRuleAssociationResource) complete(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctest-dor-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  azure_monitor_metrics_destination {
    name = "acctest-amm-%d"
  }

  windows_event_log_data_source {
    name          = "cloudSecurityTeamEvents"
    streams       = ["Microsoft-WindowsEvent"]
    xpath_queries = ["Security!"]
  }

  data_flows {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["acctest-amm-%d"]
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-%d"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-%d"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctest-ni-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctest-vm-%d"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.test.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_monitor_data_collection_rule_association" "test" {
  name                    = "configurationAccessEndpoint"
  virtual_machine_id      = azurerm_virtual_machine.test.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.test.id
  description             = "this is description"
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}

func (r MonitorDataCollectionRuleAssociationResource) endpoint(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dcr-%d"
  location = "%s"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctest-dcr-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-%d"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-%d"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctest-ni-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctest-vm-%d"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.test.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_monitor_data_collection_rule_association" "test" {
  name                        = "configurationAccessEndpoint"
  virtual_machine_id          = azurerm_virtual_machine.test.id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.test.id
  description                 = "this is description"
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger, data.RandomInteger)
}
