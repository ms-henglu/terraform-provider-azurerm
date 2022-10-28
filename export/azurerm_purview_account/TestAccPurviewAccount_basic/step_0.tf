
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221028165423404250"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221028165423404250"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
