
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230825025149013919"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230825025149013919"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230825025149013919"

  identity {
    type = "SystemAssigned"
  }
}
