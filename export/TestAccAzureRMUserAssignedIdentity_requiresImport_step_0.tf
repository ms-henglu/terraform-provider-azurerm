
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004608475463"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest90ix8"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
