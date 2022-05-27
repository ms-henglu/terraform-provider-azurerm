
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527024517095942"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestte7vu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
