
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012108828805"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                    = "acctest-SS-220916012108828805"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  incoming_traffic_policy = "AllowVirtualNetworksOnly"
  tags = {
    ENV = "Staging"
  }
}
