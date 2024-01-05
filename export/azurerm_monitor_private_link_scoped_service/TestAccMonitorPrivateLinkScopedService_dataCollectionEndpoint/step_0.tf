
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-plss-240105064223038045"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                          = "acctest-dce-240105064223038045"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false
}

resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-pls-240105064223038045"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_monitor_private_link_scoped_service" "test" {
  name                = "acctest-plss-240105064223038045"
  resource_group_name = azurerm_resource_group.test.name
  scope_name          = azurerm_monitor_private_link_scope.test.name
  linked_resource_id  = azurerm_monitor_data_collection_endpoint.test.id
}
