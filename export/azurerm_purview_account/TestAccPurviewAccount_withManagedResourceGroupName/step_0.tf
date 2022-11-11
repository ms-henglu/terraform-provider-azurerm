
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221111021033962614"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw221111021033962614"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-221111021033962614"

  identity {
    type = "SystemAssigned"
  }
}
