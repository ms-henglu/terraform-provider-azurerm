

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-220623223427017646"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                = "testAccFrontDoorWAF220623223427017646"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_frontdoor_firewall_policy" "import" {
  name                = azurerm_frontdoor_firewall_policy.test.name
  resource_group_name = azurerm_frontdoor_firewall_policy.test.resource_group_name
}
