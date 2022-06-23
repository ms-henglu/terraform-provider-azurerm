
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234034333743"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestr07fz"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
