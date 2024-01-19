


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240119025952420588"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccntirp"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240119025952420588"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw240119025952420588"
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
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

data "azurerm_client_config" "current" {}


resource "azurerm_synapse_role_assignment" "test" {
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  role_name            = "Synapse SQL Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_synapse_firewall_rule.test]
}


resource "azurerm_synapse_role_assignment" "import" {
  synapse_workspace_id = azurerm_synapse_role_assignment.test.synapse_workspace_id
  role_name            = azurerm_synapse_role_assignment.test.role_name
  principal_id         = azurerm_synapse_role_assignment.test.principal_id
}
