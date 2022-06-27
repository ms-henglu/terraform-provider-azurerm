
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627132138120540"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestgdz7j"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
