
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527715654"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                    = "acctestpublicip-240119025527715654"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}
