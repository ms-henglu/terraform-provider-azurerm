
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221104005814281910"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221104005814281910"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
