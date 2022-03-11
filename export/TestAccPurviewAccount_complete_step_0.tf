
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220311033003706764"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                   = "acctestsw220311033003706764"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  public_network_enabled = false

  tags = {
    ENV = "Test"
  }
}
