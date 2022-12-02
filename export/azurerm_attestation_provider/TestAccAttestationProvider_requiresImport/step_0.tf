

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221202035142459191"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap3japh8tzfe"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
