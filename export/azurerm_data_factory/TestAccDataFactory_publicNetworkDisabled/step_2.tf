
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221111020338607418"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221111020338607418"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
