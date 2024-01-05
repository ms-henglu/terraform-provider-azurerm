
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-240105061416078388"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw240105061416078388"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-240105061416078388"

  identity {
    type = "SystemAssigned"
  }
}
