

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230106034119788051"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapmcr6k9xe9s"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
