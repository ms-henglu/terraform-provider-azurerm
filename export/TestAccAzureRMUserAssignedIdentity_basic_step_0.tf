
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045011935116"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestjfnzw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
