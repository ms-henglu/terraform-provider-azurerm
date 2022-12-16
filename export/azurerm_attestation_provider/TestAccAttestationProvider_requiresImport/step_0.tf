

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221216013106093247"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap2lkpl9apf6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
