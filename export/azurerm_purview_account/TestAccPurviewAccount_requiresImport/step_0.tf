
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230922061758792470"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230922061758792470"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
