
	
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-221124182433869647"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccaxhd7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "test_endpoint" {
  name                     = "acctestacceaxhd7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-221124182433869647"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw221124182433869647"
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
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}


resource "azurerm_synapse_managed_private_endpoint" "test" {
  name                 = "acctestEndpoint221124182433869647"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  target_resource_id   = azurerm_storage_account.test_endpoint.id
  subresource_name     = "blob"

  depends_on = [azurerm_synapse_firewall_rule.test]
}


resource "azurerm_synapse_managed_private_endpoint" "import" {
  name                 = azurerm_synapse_managed_private_endpoint.test.name
  synapse_workspace_id = azurerm_synapse_managed_private_endpoint.test.synapse_workspace_id
  target_resource_id   = azurerm_synapse_managed_private_endpoint.test.target_resource_id
  subresource_name     = azurerm_synapse_managed_private_endpoint.test.subresource_name
}
