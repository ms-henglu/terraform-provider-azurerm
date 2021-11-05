
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-adf-211105025858645340"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestdf211105025858645340"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccof6kf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_data_factory_managed_private_endpoint" "test" {
  name               = "acctestEndpoint211105025858645340"
  data_factory_id    = azurerm_data_factory.test.id
  target_resource_id = azurerm_storage_account.test.id
  subresource_name   = "blob"
}
