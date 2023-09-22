


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060507034917-requiresimport"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922060507034917-requiresimport"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_backend" "test" {
  name                = "acctestapi-230922060507034917"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  protocol            = "http"
  url                 = "https://acctest"
}


resource "azurerm_api_management_backend" "import" {
  name                = azurerm_api_management_backend.test.name
  resource_group_name = azurerm_api_management_backend.test.resource_group_name
  api_management_name = azurerm_api_management_backend.test.api_management_name
  protocol            = azurerm_api_management_backend.test.protocol
  url                 = azurerm_api_management_backend.test.url
}
