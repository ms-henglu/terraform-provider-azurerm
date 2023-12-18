
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231218071631594578"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231218071631594578"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice231218071631594578"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls231218071631594578"
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
