
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024615248614"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                     = "acctesteventhubnamespace-211210024615248614"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku                      = "Standard"
  capacity                 = 1
  auto_inflate_enabled     = false
  maximum_throughput_units = 0
}
