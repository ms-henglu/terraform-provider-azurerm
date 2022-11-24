


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202610645"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221124181202610645"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-221124181202610645"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}


resource "azurerm_api_management_api" "import" {
  name                = azurerm_api_management_api.test.name
  resource_group_name = azurerm_api_management_api.test.resource_group_name
  api_management_name = azurerm_api_management_api.test.api_management_name
  display_name        = azurerm_api_management_api.test.display_name
  path                = azurerm_api_management_api.test.path
  protocols           = azurerm_api_management_api.test.protocols
  revision            = azurerm_api_management_api.test.revision
}
