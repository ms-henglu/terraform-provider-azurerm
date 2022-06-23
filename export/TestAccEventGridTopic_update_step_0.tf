
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223405140119"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220623223405140119"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
