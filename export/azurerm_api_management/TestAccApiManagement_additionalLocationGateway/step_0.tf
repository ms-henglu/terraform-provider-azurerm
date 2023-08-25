
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825023946803908"
  location = "West Europe"
}


resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-230825023946803908"
  location = "West US 2"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230825023946803908"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Premium_2"

  additional_location {
    location         = azurerm_resource_group.test2.location
    gateway_disabled = true
  }
}
