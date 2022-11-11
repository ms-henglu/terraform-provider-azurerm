
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221111014111918919"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw221111014111918919"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-221111014111918919"

  identity {
    type = "SystemAssigned"
  }
}
