
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211203013707583250"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211203013707583250"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
