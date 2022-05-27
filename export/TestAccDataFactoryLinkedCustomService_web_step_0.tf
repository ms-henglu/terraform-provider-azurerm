
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220527034050433041"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220527034050433041"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls220527034050433041"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "Web"
  type_properties_json = <<JSON
{
  "authenticationType": "Anonymous",
  "url": "http://www.bing.com"
}
JSON
}
