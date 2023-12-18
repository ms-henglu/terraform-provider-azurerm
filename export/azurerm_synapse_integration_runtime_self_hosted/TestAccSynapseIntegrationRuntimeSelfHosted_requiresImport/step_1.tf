


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-231218072719598670"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa0uao7"
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
  name               = "acctest-231218072719598670"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestdf231218072719598670"
  location                             = azurerm_resource_group.test.location
  resource_group_name                  = azurerm_resource_group.test.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  managed_virtual_network_enabled      = true
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_firewall_rule" "test" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_integration_runtime_self_hosted" "test" {
  name                 = "acctestSIR231218072719598670"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  description          = "test"
}


resource "azurerm_synapse_integration_runtime_self_hosted" "import" {
  name                 = azurerm_synapse_integration_runtime_self_hosted.test.name
  synapse_workspace_id = azurerm_synapse_integration_runtime_self_hosted.test.synapse_workspace_id
}
