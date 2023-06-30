
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033215163373"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                     = "acctesteventhubnamespace-230630033215163373"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku                      = "Standard"
  capacity                 = 1
  auto_inflate_enabled     = true
  maximum_throughput_units = 1
}
