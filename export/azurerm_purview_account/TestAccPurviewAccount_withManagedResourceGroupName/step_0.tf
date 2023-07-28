
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230728032927850948"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230728032927850948"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230728032927850948"

  identity {
    type = "SystemAssigned"
  }
}
