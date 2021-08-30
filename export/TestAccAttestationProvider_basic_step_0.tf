

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210830083655630129"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqa6xhvir99"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
