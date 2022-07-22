
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220722035830458116"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220722035830458116"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220722035830458116"

  identity {
    type = "SystemAssigned"
  }
}
