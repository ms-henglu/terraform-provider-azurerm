
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034746877295"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                    = "acctest-SS-220527034746877295"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  incoming_traffic_policy = "AllowVirtualNetworksOnly"
  tags = {
    ENV = "Staging"
  }
}
