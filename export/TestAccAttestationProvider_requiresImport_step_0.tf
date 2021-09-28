

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210928055142030984"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap6d2l34n7gb"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
