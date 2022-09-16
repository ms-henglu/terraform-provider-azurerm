
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eh-220916011459582699"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220916011459582699"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}
