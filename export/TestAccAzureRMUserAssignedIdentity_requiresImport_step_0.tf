
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053607679845"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestmt92s"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
