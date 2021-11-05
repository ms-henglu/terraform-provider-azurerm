

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211105025636059082"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4i1u74vqha"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
