
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022656813583"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                          = "acctestIoTDPS-220610022656813583"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
