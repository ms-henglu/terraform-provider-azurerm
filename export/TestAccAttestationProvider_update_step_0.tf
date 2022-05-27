

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220527023841997299"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapo3r1uezjfg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
