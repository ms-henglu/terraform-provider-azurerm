
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627134758541075"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesty2bo8"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
