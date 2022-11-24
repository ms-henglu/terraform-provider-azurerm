

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202625913-import"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221124181202625913-import"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_backend" "test" {
  name                = "acctestapi-221124181202625913"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  protocol            = "http"
  url                 = "https://acctest"
}
