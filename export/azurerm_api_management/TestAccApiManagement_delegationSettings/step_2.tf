
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033744197426"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240112033744197426"
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
