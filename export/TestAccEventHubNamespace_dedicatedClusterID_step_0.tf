
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044526429872"
  location = "West Europe"
}

resource "azurerm_eventhub_cluster" "test" {
  name                = "acctesteventhubcluster-220121044526429872"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Dedicated_1"
}

resource "azurerm_eventhub_namespace" "test" {
  name                 = "acctesteventhubnamespace-220121044526429872"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  sku                  = "Standard"
  capacity             = "2"
  dedicated_cluster_id = azurerm_eventhub_cluster.test.id
}
