

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825042555151121"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapr1im8f4tar"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
