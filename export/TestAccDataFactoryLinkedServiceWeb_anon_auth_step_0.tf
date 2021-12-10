
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210024512768525"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211210024512768525"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_web" "test" {
  name                = "acctestlsweb211210024512768525"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  authentication_type = "Anonymous"
  url                 = "http://www.bing.com"
}
