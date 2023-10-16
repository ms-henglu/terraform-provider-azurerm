
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033300959331"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231016033300959331"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  sign_in {
    enabled = true
  }

  sign_up {
    enabled = true

    terms_of_service {
      enabled          = true
      consent_required = false
      text             = "Lorem Ipsum Dolor Morty"
    }
  }
}
