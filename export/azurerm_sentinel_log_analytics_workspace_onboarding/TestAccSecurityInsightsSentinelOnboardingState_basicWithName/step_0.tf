
provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230810144203312093"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230810144203312093"
  location = "West Europe"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}
