
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-240119025651714275"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                   = "acctestsw240119025651714275"
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
