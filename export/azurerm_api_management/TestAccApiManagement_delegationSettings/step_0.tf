
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064257536676"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230929064257536676"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  delegation {
    url                       = "https://google.com"
    subscriptions_enabled     = true
    validation_key            = "aW50ZWdyYXRpb24mMjAyMzAzMTAxODMwJkxRaUxzcUVsaUpEaHJRK01YZkJYV3paUi9qdzZDSWMrazhjUXB0bVdyTGxKcVYrd0R4OXRqMGRzTWZXU3hmeGQ0a2V0WjcrcE44U0dJdDNsYUQ3Rk5BPT0="
    user_registration_enabled = true
  }
}
