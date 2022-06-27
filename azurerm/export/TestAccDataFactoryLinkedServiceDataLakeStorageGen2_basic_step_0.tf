
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627125805913047"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220627125805913047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                  = "acctestDataLake220627125805913047"
  resource_group_name   = azurerm_resource_group.test.name
  data_factory_name     = azurerm_data_factory.test.name
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = "testkey"
  url                   = "https://test.azure.com"
}
