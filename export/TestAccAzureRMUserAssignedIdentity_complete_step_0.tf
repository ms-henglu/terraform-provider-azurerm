
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042546057321"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestte4e1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
