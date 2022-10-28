
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172133629706"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                                      = "acctesteg-221028172133629706"
  location                                  = azurerm_resource_group.test.location
  resource_group_name                       = azurerm_resource_group.test.name
  local_auth_enabled                        = false
  auto_create_topic_with_first_subscription = false
  auto_delete_topic_with_last_subscription  = false
}
