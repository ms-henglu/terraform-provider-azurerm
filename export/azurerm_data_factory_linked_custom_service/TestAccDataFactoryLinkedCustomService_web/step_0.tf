
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230804025818547431"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230804025818547431"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls230804025818547431"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "Web"
  type_properties_json = <<JSON
{
  "authenticationType": "Anonymous",
  "url": "http://www.bing.com"
}
JSON
}
