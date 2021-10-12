package synapse_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/check"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/synapse/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

type IntegrationRuntimeSelfHostedResource struct {
}

func TestAccSynapseIntegrationRuntimeSelfHosted_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_synapse_integration_runtime_self_hosted", "test")
	r := IntegrationRuntimeSelfHostedResource{}

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

func TestAccSynapseIntegrationRuntimeSelfHosted_rbac(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_synapse_integration_runtime_self_hosted", "test")
	r := IntegrationRuntimeSelfHostedResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.rbac(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("rbac_authorization.#").HasValue("1"),
			),
		},
		data.ImportStep(),
	})
}

func TestAccSynapseIntegrationRuntimeSelfHosted_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_synapse_integration_runtime_self_hosted", "test")
	r := IntegrationRuntimeSelfHostedResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func (r IntegrationRuntimeSelfHostedResource) Exists(ctx context.Context, clients *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := parse.IntegrationRuntimeID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := clients.Synapse.IntegrationRuntimesClient.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, "")
	if err != nil {
		return nil, fmt.Errorf("reading %s: %+v", id, err)
	}
	return utils.Bool(resp.ID != nil), nil
}

func (r IntegrationRuntimeSelfHostedResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-%d"
  location = "%s"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa%s"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-%d"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestdf%d"
  location                             = azurerm_resource_group.test.location
  resource_group_name                  = azurerm_resource_group.test.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  managed_virtual_network_enabled      = true
}

resource "azurerm_synapse_firewall_rule" "test" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
`, data.RandomInteger, data.Locations.Primary, data.RandomString, data.RandomInteger, data.RandomInteger)
}

func (r IntegrationRuntimeSelfHostedResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

resource "azurerm_synapse_integration_runtime_self_hosted" "test" {
  name                 = "acctestSIR%d"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  description          = "test"
}
`, r.template(data), data.RandomInteger)
}

func (r IntegrationRuntimeSelfHostedResource) rbac(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-%[2]d"
  location = "%[1]s"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-%[2]d"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
  name                = "acctpip-%[2]d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-%[2]d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm%[3]s"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  vm_size               = "Standard_F4"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "acctvm%[3]s"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    timezone           = "Pacific Standard Time"
    provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "test" {
  name                 = "acctestExt-%[2]d"
  virtual_machine_id   = azurerm_virtual_machine.test.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = jsonencode({
    "fileUris"         = ["https://raw.githubusercontent.com/Azure/azure-quickstart-templates/00b79d2102c88b56502a63041936ef4dd62cf725/101-vms-with-selfhost-integration-runtime/gatewayInstall.ps1"],
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File gatewayInstall.ps1 ${azurerm_synapse_integration_runtime_self_hosted.host.authorization_key_primary} && timeout /t 120"
  })
}

resource "azurerm_resource_group" "host" {
  name     = "acctesthostRG-synapse-%[2]d"
  location = "%[1]s"
}

resource "azurerm_storage_account" "host" {
  name                     = "acchost%[3]s"
  location                 = azurerm_resource_group.host.location
  resource_group_name      = azurerm_resource_group.host.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "host" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.host.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "host" {
  name               = "acctest-%[2]d"
  storage_account_id = azurerm_storage_account.host.id
}

resource "azurerm_synapse_workspace" "host" {
  name                                 = "acchost%[2]d"
  location                             = azurerm_resource_group.host.location
  resource_group_name                  = azurerm_resource_group.host.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.host.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  managed_virtual_network_enabled      = true
}

resource "azurerm_synapse_firewall_rule" "host" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.host.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

resource "azurerm_synapse_integration_runtime_self_hosted" "host" {
  name                 = "acctestSIR%[2]d"
  synapse_workspace_id = azurerm_synapse_workspace.host.id
  description          = "test"
}

resource "azurerm_resource_group" "target" {
  name     = "acctesttargetRG-%[2]d"
  location = "%[1]s"
}

resource "azurerm_role_assignment" "target" {
  scope                = azurerm_synapse_integration_runtime_self_hosted.host.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_synapse_workspace.target.identity[0].principal_id
}

resource "azurerm_storage_account" "target" {
  name                     = "acctarget%[3]s"
  location                 = azurerm_resource_group.target.location
  resource_group_name      = azurerm_resource_group.target.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "target" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.target.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "target" {
  name               = "acctest-%[2]d"
  storage_account_id = azurerm_storage_account.target.id
}

resource "azurerm_synapse_workspace" "target" {
  name                                 = "acctarget%[2]d"
  location                             = azurerm_resource_group.target.location
  resource_group_name                  = azurerm_resource_group.target.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.target.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  managed_virtual_network_enabled      = true

}

resource "azurerm_synapse_firewall_rule" "target" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.target.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_integration_runtime_self_hosted" "target" {
  name                 = "acctestSIR%[2]d"
  synapse_workspace_id = azurerm_synapse_workspace.target.id
  description          = "test"
  rbac_authorization {
    resource_id = azurerm_synapse_integration_runtime_self_hosted.host.id
  }

  depends_on = [azurerm_role_assignment.target, azurerm_virtual_machine_extension.test]
}
`, data.Locations.Primary, data.RandomInteger, data.RandomString)
}

func (r IntegrationRuntimeSelfHostedResource) requiresImport(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

resource "azurerm_synapse_integration_runtime_self_hosted" "import" {
  name                 = azurerm_synapse_integration_runtime_self_hosted.test.name
  synapse_workspace_id = azurerm_synapse_integration_runtime_self_hosted.test.synapse_workspace_id
}
`, r.basic(data))
}
