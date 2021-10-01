

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001020504349269"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapeoon9diw9p"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
