
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002921118761"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220826002921118761"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_saved_search" "test" {
  name                       = "acctestLASS-220826002921118761"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  category     = "Saved Search Test Category"
  display_name = "Create or Update Saved Search Test"
  query        = "Heartbeat | summarize Count() by Computer | take a"

  function_alias      = "heartbeat_func"
  function_parameters = ["a:int=1"]
}
