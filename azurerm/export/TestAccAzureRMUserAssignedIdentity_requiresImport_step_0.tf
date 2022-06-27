
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627132138120442"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestzagia"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
