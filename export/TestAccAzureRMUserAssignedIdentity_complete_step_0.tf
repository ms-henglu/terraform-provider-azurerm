
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015050388255"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestiy2j6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
