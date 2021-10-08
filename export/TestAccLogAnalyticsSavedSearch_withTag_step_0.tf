
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044559893158"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211008044559893158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_saved_search" "test" {
  name                       = "acctestLASS-211008044559893158"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  category     = "Saved Search Test Category"
  display_name = "Create or Update Saved Search Test"
  query        = "Heartbeat | summarize Count() by Computer | take a"

  tags = {
    "Environment" = "Test"
  }
}
