
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429075706116625"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestnowx6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
