
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230613072459394194"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230613072459394194"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
