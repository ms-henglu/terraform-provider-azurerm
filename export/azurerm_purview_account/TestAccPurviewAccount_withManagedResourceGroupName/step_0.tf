
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230818024640153775"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230818024640153775"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230818024640153775"

  identity {
    type = "SystemAssigned"
  }
}
