
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125405930027"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesto49v1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
