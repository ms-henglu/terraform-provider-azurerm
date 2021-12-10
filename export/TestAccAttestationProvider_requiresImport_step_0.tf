

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211210034343350732"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapcxq7jpyiwr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
