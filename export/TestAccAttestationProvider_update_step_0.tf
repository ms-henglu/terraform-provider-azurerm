

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220603004538660411"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapvu0nq4k3qe"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
