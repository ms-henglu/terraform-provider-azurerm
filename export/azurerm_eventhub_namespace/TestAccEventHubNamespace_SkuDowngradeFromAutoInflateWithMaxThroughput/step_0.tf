
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033936847172"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                     = "acctesteventhubnamespace-231016033936847172"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku                      = "Standard"
  capacity                 = "2"
  auto_inflate_enabled     = true
  maximum_throughput_units = 25
}
