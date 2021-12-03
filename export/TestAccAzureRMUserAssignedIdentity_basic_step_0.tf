
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161645425446"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestr0f7m"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
