
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163702020255"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvo7ej"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
