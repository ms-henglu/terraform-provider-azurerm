
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015559861833"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211029015559861833"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
