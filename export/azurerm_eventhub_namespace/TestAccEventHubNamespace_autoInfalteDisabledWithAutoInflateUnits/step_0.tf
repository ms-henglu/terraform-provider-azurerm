
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025039076206"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                     = "acctesteventhubnamespace-240119025039076206"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku                      = "Standard"
  capacity                 = 1
  auto_inflate_enabled     = false
  maximum_throughput_units = 0
}
