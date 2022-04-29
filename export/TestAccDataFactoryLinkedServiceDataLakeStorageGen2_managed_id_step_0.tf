
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220429065415681215"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220429065415681215"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                 = "acctestDataLake220429065415681215"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true
  url                  = "https://test.azure.com"
}
