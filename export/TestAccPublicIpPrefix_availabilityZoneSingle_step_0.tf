
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014608600657"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-211015014608600657"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  availability_zone   = "1"
}
