

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220715014150140496"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap84ma6tf9oy"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
