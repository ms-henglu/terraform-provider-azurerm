

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-230613072255518049"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-230613072255518049"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
