
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221021034458850337"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221021034458850337"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
