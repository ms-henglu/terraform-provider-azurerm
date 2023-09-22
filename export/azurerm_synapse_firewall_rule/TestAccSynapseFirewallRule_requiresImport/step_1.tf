


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230922062049745060"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccoq1x6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230922062049745060"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230922062049745060"
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
  name                 = "FirewallRule230922062049745060"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_firewall_rule" "import" {
  name                 = azurerm_synapse_firewall_rule.test.name
  synapse_workspace_id = azurerm_synapse_firewall_rule.test.synapse_workspace_id
  start_ip_address     = azurerm_synapse_firewall_rule.test.start_ip_address
  end_ip_address       = azurerm_synapse_firewall_rule.test.end_ip_address
}
