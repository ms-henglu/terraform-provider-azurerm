
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064405148150"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestrx8nl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
