
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220415030948161361"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220415030948161361"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220415030948161361"

  identity {
    type = "SystemAssigned"
  }
}
