

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230227032235663502"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap0v1i1ttkme"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
