
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220513023141071965"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220513023141071965"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name            = "acctestlsblob220513023141071965"
  data_factory_id = azurerm_data_factory.test.id
  url             = "foo"
  key             = "bar"
}
