

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-230825024934297916"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-230825024934297916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
