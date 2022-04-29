

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220429065151350325"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapneg0b4i2gb"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
