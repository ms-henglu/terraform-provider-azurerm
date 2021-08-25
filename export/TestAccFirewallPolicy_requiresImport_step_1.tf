


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210825044817331165"
  location = "West Europe"
}


resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210825044817331165"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_firewall_policy" "import" {
  name                = azurerm_firewall_policy.test.name
  resource_group_name = azurerm_firewall_policy.test.resource_group_name
  location            = azurerm_firewall_policy.test.location
}
