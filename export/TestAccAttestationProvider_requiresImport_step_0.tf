

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220630223412141945"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxb700r6dks"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
