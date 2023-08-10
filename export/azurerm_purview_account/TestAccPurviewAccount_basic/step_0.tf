
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230810144107338307"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230810144107338307"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
