
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230113181600337892"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230113181600337892"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
