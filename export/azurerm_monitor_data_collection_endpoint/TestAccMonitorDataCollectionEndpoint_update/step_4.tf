

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionEndpoint-221221204605942962"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-221221204605942962"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
