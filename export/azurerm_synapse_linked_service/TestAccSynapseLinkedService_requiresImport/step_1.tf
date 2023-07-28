


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230728030835025506"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalxj8a"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230728030835025506"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230728030835025506"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  managed_virtual_network_enabled      = true
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_firewall_rule" "test" {
  name                 = "allowAll"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_linked_service" "test" {
  name                 = "acctestls230728030835025506"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON

  depends_on = [
    azurerm_synapse_firewall_rule.test,
  ]
}


resource "azurerm_synapse_linked_service" "import" {
  name                 = azurerm_synapse_linked_service.test.name
  synapse_workspace_id = azurerm_synapse_linked_service.test.synapse_workspace_id
  type                 = azurerm_synapse_linked_service.test.type
  type_properties_json = azurerm_synapse_linked_service.test.type_properties_json
}
