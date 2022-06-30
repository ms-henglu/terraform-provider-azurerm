
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630211116202815"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestgl6xq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
