
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221222035205143843"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw221222035205143843"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-221222035205143843"

  identity {
    type = "SystemAssigned"
  }
}
