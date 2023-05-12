

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-230512004421743515"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-230512004421743515"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
