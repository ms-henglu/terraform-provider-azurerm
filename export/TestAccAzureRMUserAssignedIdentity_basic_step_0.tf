
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082714323030"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestx76h6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
