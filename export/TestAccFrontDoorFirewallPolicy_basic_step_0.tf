
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-220826002750320679"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                = "testAccFrontDoorWAF220826002750320679"
  resource_group_name = azurerm_resource_group.test.name
}
