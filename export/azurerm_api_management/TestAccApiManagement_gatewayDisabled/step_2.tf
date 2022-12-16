
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013034419704"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221216013034419704"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Premium_1"
  gateway_disabled    = true
  additional_location {
    location = "West US 2"
  }
}
