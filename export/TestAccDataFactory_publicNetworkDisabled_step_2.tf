
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825042745283833"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF210825042745283833"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
