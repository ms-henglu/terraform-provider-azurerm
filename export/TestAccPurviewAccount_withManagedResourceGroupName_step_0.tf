
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220407231333107440"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220407231333107440"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220407231333107440"

  identity {
    type = "SystemAssigned"
  }
}
