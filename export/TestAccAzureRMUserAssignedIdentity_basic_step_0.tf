
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042738718847"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvf183"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
