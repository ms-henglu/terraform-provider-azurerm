
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021614656188"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230421021614656188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Premium_1"
  additional_location {
    location = "West US 2"
  }
}
