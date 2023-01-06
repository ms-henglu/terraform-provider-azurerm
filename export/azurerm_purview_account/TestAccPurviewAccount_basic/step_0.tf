
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230106034924564994"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230106034924564994"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
