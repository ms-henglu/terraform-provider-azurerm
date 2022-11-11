

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fwpolicy-RCG-221111013552032769"
  location = "West Europe"
}
resource "azurerm_firewall_policy" "test" {
  name                = "acctest-fwpolicy-RCG-221111013552032769"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_firewall_policy_rule_collection_group" "test" {
  name               = "acctest-fwpolicy-RCG-221111013552032769"
  firewall_policy_id = azurerm_firewall_policy.test.id
  priority           = 500
}

resource "azurerm_firewall_policy_rule_collection_group" "import" {
  name               = azurerm_firewall_policy_rule_collection_group.test.name
  firewall_policy_id = azurerm_firewall_policy_rule_collection_group.test.firewall_policy_id
  priority           = azurerm_firewall_policy_rule_collection_group.test.priority
}
