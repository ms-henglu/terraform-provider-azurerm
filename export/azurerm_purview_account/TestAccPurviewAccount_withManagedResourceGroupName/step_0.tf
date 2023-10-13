
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-231013044116291371"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw231013044116291371"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-231013044116291371"

  identity {
    type = "SystemAssigned"
  }
}
