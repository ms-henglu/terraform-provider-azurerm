
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-230127045436224341"
  location = "West Europe"
}

resource "azurerm_eventhub_cluster" "test" {
  name                = "acctesteventhubclusTER-230127045436224341"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Dedicated_1"
}
