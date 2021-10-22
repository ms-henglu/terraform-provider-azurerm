

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211022001650142232"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxsq8rbsmqt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
