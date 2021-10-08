
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044745610777"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-211008044745610777"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Staging"
  }
}
