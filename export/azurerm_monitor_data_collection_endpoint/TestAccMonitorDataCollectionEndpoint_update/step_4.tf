

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-231020041503956937"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-231020041503956937"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
