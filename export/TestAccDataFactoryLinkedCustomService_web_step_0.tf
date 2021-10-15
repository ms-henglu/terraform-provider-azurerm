
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014528489125"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014528489125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls211015014528489125"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "Web"
  type_properties_json = <<JSON
{
  "authenticationType": "Anonymous",
  "url": "http://www.bing.com"
}
JSON
}
