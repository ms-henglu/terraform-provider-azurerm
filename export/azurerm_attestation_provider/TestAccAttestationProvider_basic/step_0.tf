

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230120054236436960"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprk9x8msbyx"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
