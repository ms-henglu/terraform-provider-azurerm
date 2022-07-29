
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220729033145961457"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220729033145961457"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220729033145961457"

  identity {
    type = "SystemAssigned"
  }
}
