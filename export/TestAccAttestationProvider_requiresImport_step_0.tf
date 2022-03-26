

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220326010127571783"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapyr14b7fkg2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
