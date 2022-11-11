
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014332755998"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                    = "acctest-SS-221111014332755998"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  incoming_traffic_policy = "AllowVirtualNetworksOnly"
  tags = {
    ENV = "Staging"
  }
}
