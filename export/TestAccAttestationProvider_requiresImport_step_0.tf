

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220722034826832821"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4b6al2jgvp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
