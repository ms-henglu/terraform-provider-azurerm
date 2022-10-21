
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221021034458852761"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw221021034458852761"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-221021034458852761"

  identity {
    type = "SystemAssigned"
  }
}
