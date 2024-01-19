
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025909553372"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                    = "acctest-SS-240119025909553372"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  incoming_traffic_policy = "AllowVirtualNetworksOnly"
  tags = {
    ENV = "Staging"
  }
}
