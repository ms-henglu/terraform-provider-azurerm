


// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220407230659638448"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapp2kqsit37h"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_attestation_provider" "import" {
  name                = azurerm_attestation_provider.test.name
  resource_group_name = azurerm_attestation_provider.test.resource_group_name
  location            = azurerm_attestation_provider.test.location
}
