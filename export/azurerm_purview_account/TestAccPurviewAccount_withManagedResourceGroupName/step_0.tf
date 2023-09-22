
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230922054740671612"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230922054740671612"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230922054740671612"

  identity {
    type = "SystemAssigned"
  }
}
