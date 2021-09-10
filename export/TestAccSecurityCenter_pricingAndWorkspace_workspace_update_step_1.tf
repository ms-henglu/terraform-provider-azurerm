
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_subscription_pricing" "test" {
  tier = "Standard"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sc-210910021838877026"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test2" {
  name                = "acctest-210910021838877026-2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_security_center_workspace" "test" {
  scope        = "/subscriptions/ARM_SUBSCRIPTION_ID"
  workspace_id = azurerm_log_analytics_workspace.test2.id
}
