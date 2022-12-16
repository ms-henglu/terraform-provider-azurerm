

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221216013106110593"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1v1d7b0lvk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
