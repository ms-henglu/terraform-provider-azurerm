
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221021031635392622"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw221021031635392622"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-221021031635392622"

  identity {
    type = "SystemAssigned"
  }
}
