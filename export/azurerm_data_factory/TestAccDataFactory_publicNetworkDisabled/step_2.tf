
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221019060523677745"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221019060523677745"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
