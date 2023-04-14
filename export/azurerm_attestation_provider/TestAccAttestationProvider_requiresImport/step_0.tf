

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230414020744337588"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap66ma0hjwzk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
