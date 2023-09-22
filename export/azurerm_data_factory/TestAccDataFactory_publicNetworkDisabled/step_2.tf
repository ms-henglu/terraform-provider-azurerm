
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230922054015307163"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230922054015307163"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
