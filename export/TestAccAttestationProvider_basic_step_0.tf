

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220218070424949202"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapkd9be6074h"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
