

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-240119022447670774"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-240119022447670774"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
