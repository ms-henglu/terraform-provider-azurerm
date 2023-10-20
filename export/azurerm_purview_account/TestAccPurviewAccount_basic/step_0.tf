
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-231020041723212268"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw231020041723212268"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
