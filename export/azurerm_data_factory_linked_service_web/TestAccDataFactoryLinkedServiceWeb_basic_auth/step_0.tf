
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759700589"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759700589"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb231016033759700589"
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Basic"
  url                 = "http://www.bing.com"
  username            = "foo"
  password            = "bar"
}
