

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221117230512481032"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapk3pc0t9929"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
