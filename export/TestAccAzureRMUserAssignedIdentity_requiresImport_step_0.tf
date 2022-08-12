
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015448567922"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestaab1e"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
