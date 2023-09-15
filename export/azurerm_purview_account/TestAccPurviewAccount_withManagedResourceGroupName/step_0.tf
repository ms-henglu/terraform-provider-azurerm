
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230915024041999731"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw230915024041999731"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-230915024041999731"

  identity {
    type = "SystemAssigned"
  }
}
