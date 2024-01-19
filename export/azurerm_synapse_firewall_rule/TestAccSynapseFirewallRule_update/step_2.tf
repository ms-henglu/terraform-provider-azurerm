

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240119025952427763"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccgd682"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240119025952427763"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw240119025952427763"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_synapse_firewall_rule" "test" {
  name                 = "FirewallRule240119025952427763"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "10.0.17.62"
  end_ip_address       = "10.0.17.62"
}
