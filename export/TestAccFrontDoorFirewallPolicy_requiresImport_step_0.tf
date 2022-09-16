
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-220916011515769789"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                = "testAccFrontDoorWAF220916011515769789"
  resource_group_name = azurerm_resource_group.test.name
}
