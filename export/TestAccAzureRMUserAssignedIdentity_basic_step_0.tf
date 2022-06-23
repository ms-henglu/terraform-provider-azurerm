
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223657220057"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctests83zf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
