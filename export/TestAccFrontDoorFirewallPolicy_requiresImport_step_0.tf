
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-220527034212114759"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                = "testAccFrontDoorWAF220527034212114759"
  resource_group_name = azurerm_resource_group.test.name
}
