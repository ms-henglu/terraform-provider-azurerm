
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825025712784607"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210825025712784607"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name                = "acctestlsblob210825025712784607"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = "foo"
  key                 = "bar"
}
