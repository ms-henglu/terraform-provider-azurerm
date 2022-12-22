
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221222035205140585"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221222035205140585"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
