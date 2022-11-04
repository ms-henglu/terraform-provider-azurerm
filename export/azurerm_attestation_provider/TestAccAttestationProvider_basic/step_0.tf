

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221104005115618915"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapmzt8kw0gyt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
