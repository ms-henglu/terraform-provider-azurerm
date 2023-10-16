

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034159731134"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034159731134"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_saved_search" "test" {
  name                       = "acctestLASS-231016034159731134"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  category     = "Saved Search Test Category"
  display_name = "Create or Update Saved Search Test"
  query        = "Heartbeat | summarize Count() by Computer | take a"
}


resource "azurerm_log_analytics_saved_search" "import" {
  name                       = azurerm_log_analytics_saved_search.test.name
  log_analytics_workspace_id = azurerm_log_analytics_saved_search.test.log_analytics_workspace_id

  category     = azurerm_log_analytics_saved_search.test.category
  display_name = azurerm_log_analytics_saved_search.test.display_name
  query        = azurerm_log_analytics_saved_search.test.query
}
