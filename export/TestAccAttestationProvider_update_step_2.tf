

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220211130203926890"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapvrgxk8zt3x"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    ENV = "Test"
  }
}
