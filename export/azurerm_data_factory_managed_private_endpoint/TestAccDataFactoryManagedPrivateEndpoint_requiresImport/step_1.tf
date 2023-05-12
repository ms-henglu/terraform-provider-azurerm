
	
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-adf-230512010553196844"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestdf230512010553196844"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestacc2hubl"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_factory_managed_private_endpoint" "test" {
  name               = "acctestEndpoint230512010553196844"
  data_factory_id    = azurerm_data_factory.test.id
  target_resource_id = azurerm_storage_account.test.id
  subresource_name   = "blob"
}


resource "azurerm_data_factory_managed_private_endpoint" "import" {
  name               = azurerm_data_factory_managed_private_endpoint.test.name
  data_factory_id    = azurerm_data_factory_managed_private_endpoint.test.data_factory_id
  target_resource_id = azurerm_data_factory_managed_private_endpoint.test.target_resource_id
  subresource_name   = azurerm_data_factory_managed_private_endpoint.test.subresource_name
}
