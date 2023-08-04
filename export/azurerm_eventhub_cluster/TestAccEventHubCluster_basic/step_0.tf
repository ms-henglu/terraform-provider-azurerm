
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-230804025946991383"
  location = "West Europe"
}

resource "azurerm_eventhub_cluster" "test" {
  name                = "acctesteventhubclusTER-230804025946991383"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Dedicated_1"
}
