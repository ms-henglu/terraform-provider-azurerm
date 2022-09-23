
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220923012229376419"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220923012229376419"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220923012229376419"

  identity {
    type = "SystemAssigned"
  }
}
