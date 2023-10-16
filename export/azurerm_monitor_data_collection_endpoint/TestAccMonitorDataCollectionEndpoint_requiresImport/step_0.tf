

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-231016034326112202"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-231016034326112202"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
