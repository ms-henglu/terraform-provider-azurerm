
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055119972988"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                       = "acctestAM-210928055119972988"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  publisher_name             = "pub1"
  publisher_email            = "pub1@email.com"
  sku_name                   = "Consumption_0"
  client_certificate_enabled = true
}
