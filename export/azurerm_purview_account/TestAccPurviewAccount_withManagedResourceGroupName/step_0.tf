
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230609091849619534"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230609091849619534"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230609091849619534"

  identity {
    type = "SystemAssigned"
  }
}
