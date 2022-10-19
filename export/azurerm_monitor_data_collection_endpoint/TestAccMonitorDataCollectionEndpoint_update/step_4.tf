

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-221019060846529606"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-221019060846529606"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
