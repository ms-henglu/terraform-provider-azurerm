

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825044500301817"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxqa10ljhkn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
