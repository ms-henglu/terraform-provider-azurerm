
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fwpolicy-RCG-211105035924473964"
  location = "West Europe"
}
resource "azurerm_firewall_policy" "test" {
  name                = "acctest-fwpolicy-RCG-211105035924473964"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_firewall_policy_rule_collection_group" "test" {
  name               = "acctest-fwpolicy-RCG-211105035924473964"
  firewall_policy_id = azurerm_firewall_policy.test.id
  priority           = 500
}
