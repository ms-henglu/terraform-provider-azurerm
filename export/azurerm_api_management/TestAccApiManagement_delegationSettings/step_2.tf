
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023425132437"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230818023425132437"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  delegation {
    subscriptions_enabled     = false
    user_registration_enabled = false
  }
}
