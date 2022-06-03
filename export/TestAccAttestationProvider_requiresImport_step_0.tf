

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220603004538627317"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbwadwji91b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
