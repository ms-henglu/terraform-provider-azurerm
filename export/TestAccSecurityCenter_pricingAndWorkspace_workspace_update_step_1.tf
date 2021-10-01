
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_subscription_pricing" "test" {
  tier = "Standard"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sc-211001054144766744"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test2" {
  name                = "acctest-211001054144766744-2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_security_center_workspace" "test" {
  scope        = "/subscriptions/ARM_SUBSCRIPTION_ID"
  workspace_id = azurerm_log_analytics_workspace.test2.id
}
