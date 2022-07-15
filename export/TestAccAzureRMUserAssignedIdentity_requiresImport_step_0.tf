
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004705299571"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestxz3ta"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
