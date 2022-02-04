
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204092611998667"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                       = "acctestAM-220204092611998667"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  publisher_name             = "pub1"
  publisher_email            = "pub1@email.com"
  sku_name                   = "Consumption_0"
  client_certificate_enabled = true
}
