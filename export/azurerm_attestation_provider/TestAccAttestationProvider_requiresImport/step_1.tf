


// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221222034234466459"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqafk0uafta"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_attestation_provider" "import" {
  name                = azurerm_attestation_provider.test.name
  resource_group_name = azurerm_attestation_provider.test.resource_group_name
  location            = azurerm_attestation_provider.test.location
}
