
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220712042654154560"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw220712042654154560"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-220712042654154560"

  identity {
    type = "SystemAssigned"
  }
}
