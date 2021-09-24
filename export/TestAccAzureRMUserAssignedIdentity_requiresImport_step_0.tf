
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011237869964"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestua88o"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
