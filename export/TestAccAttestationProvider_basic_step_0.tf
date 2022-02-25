

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220225034030401147"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgj04ng7k0x"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
