
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230929064753251887"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230929064753251887"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230929064753251887"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls230929064753251887"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureSearch"
  type_properties_json = <<JSON
{
  "url": "https://${azurerm_search_service.test.name}.search.windows.net",
  "key": {
    "type": "SecureString",
    "value": "${azurerm_search_service.test.primary_key}"
  }
}
JSON
}
