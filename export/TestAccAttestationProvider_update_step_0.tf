

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220326010127634458"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap3ilh7stfcn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
