
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220715014907494760"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220715014907494760"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220715014907494760"

  identity {
    type = "SystemAssigned"
  }
}
