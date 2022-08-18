
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220818235528093147"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220818235528093147"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220818235528093147"

  identity {
    type = "SystemAssigned"
  }
}
