

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fwpolicy-RCG-230316221548120444"
  location = "West Europe"
}
resource "azurerm_firewall_policy" "test" {
  name                = "acctest-fwpolicy-RCG-230316221548120444"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_firewall_policy_rule_collection_group" "test" {
  name               = "acctest-fwpolicy-RCG-230316221548120444"
  firewall_policy_id = azurerm_firewall_policy.test.id
  priority           = 500
}

resource "azurerm_firewall_policy_rule_collection_group" "import" {
  name               = azurerm_firewall_policy_rule_collection_group.test.name
  firewall_policy_id = azurerm_firewall_policy_rule_collection_group.test.firewall_policy_id
  priority           = azurerm_firewall_policy_rule_collection_group.test.priority
}
