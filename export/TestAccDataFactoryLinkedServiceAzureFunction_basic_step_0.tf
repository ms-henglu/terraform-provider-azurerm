
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127478730"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127478730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name                = "acctestlsblob211015014127478730"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = "foo"
  key                 = "bar"
}
