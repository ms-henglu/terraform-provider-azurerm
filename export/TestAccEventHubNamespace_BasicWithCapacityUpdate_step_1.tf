
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002735984926"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220826002735984926"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
  capacity            = 2
}
