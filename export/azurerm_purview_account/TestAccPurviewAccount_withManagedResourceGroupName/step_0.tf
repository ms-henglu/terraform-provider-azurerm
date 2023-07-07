
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230707010841153932"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230707010841153932"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230707010841153932"

  identity {
    type = "SystemAssigned"
  }
}
