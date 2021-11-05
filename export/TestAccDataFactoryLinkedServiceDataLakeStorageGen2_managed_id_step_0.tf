
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211105035757881457"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211105035757881457"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                 = "acctestDataLake211105035757881457"
  resource_group_name  = azurerm_resource_group.test.name
  data_factory_name    = azurerm_data_factory.test.name
  use_managed_identity = true
  url                  = "https://test.azure.com"
}
