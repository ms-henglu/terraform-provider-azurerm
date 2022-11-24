

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-221124181659535479"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test-parent" {
  name                = "acctest-networkfw-Policy-221124181659535479-parent"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-221124181659535479"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  base_policy_id      = azurerm_firewall_policy.test-parent.id
  threat_intelligence_allowlist {
    ip_addresses = ["1.1.1.1", "2.2.2.2"]
    fqdns        = ["foo.com", "bar.com"]
  }
  dns {
    servers       = ["1.1.1.1", "2.2.2.2"]
    proxy_enabled = true
  }
  tags = {
    env = "Test"
  }
}
