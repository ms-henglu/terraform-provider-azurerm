
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627131806465536"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220627131806465536"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                 = "acctestDataLake220627131806465536"
  resource_group_name  = azurerm_resource_group.test.name
  data_factory_name    = azurerm_data_factory.test.name
  use_managed_identity = true
  url                  = "https://test.azure.com"
}
