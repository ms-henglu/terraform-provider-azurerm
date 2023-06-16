
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230616075316373524"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230616075316373524"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
