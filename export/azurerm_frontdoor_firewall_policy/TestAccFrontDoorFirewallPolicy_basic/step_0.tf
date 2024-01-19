
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025100209662"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                = "testAccFrontDoorWAF240119025100209662"
  resource_group_name = azurerm_resource_group.test.name
}
