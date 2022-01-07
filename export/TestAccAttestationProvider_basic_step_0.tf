

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220107033538187804"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapi3kbf0yhfu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
