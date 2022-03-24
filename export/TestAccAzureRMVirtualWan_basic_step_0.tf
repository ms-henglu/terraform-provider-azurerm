
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324160640352336"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220324160640352336"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
