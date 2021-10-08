
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307087216"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211008044307087216"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name                = "acctestlsblob211008044307087216"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = "foo"
  key                 = "bar"
}
