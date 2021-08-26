

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210826023056412834"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapz1r8zsj486"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
