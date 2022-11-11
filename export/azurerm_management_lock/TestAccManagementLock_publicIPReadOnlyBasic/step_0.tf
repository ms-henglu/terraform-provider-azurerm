
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014148929420"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                    = "acctestpublicip-221111014148929420"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221111014148929420"
  scope      = azurerm_public_ip.test.id
  lock_level = "ReadOnly"
}
