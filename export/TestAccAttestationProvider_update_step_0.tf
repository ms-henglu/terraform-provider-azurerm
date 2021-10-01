

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001053444064771"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapep8c9jucga"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
