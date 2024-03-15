

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240315122405745509"
  location = "West Europe"
}
resource "azurerm_network_security_group" "test" {
  name                = "testnsg-batch-k13u6"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_virtual_network" "test" {
  name                = "testvn-batch-k13u6"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "testsubnet" {
  name                 = "testsn-k13u6"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchk13u6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "testaccloganalyticsk13u6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolk13u6"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 22.04"
  vm_size             = "Standard_A1"
  extensions {
    name                       = "OmsAgentForLinux"
    publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
    settings_json              = jsonencode({ "workspaceId" = "${azurerm_log_analytics_workspace.test.id}", "skipDockerProviderInstall" = true })
    protected_settings         = jsonencode({ "workspaceKey" = "${azurerm_log_analytics_workspace.test.primary_shared_key}" })
    type                       = "OmsAgentForLinux"
    type_handler_version       = "1.17"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled  = true
  }
  fixed_scale {
    target_dedicated_nodes = 1
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
