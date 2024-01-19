
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025258348535"
  location = "West Europe"
}
resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119025258348535"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  retention_in_days   = 30
}
resource "azurerm_log_analytics_workspace_table" "test" {
  name              = "AppEvents"
  workspace_id      = azurerm_log_analytics_workspace.test.id
  retention_in_days = 7
}
