
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012118614673"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestn1za8"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
