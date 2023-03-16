

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230316221033704849"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapv74lk0zb3o"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
