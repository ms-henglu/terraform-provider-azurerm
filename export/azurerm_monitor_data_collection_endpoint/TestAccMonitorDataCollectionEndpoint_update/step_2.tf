

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-230825024934299995"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                          = "acctestmdce-230825024934299995"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  kind                          = "Windows"
  public_network_access_enabled = false
  description                   = "acc test monitor_data_collection_endpoint complete"
  tags = {
    ENV = "test"
  }
}
