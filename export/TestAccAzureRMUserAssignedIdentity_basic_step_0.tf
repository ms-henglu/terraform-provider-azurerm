
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021650335885"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestia6uv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
