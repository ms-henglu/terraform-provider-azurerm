

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211015013907999500"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgdc1km4umw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
