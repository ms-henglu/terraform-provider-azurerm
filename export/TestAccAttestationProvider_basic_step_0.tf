

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210906021946216241"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapow3zrhu0vd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
