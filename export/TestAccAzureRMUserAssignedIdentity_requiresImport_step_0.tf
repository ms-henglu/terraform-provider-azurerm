
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825043055694064"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestm9zh9"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
