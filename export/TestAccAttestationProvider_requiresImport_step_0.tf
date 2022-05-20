

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220520053557898123"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapte0vfwg9et"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
