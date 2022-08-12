

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220812014629335524"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7r2fb3rjti"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
