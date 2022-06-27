

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627130754548870"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap029prc30dn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
