

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211217034913193517"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap2lg82cb7k9"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
