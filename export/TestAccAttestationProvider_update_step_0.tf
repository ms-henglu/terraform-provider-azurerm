

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220826002338234246"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap6pwq7s6d3i"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
