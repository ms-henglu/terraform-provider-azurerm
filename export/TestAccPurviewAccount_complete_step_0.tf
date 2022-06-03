
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220603005212724761"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                   = "acctestsw220603005212724761"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  public_network_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}
