
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035656510359"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestmd1yp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
