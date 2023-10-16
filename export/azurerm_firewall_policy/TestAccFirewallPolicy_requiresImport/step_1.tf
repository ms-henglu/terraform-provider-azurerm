


provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-231016033934764809"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-231016033934764809"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    Env = "Test"
  }
}

resource "azurerm_firewall_policy" "import" {
  name                = azurerm_firewall_policy.test.name
  resource_group_name = azurerm_firewall_policy.test.resource_group_name
  location            = azurerm_firewall_policy.test.location
}
