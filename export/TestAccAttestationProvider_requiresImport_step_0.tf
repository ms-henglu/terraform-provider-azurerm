

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220513022911804261"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaph30t4xdu66"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
