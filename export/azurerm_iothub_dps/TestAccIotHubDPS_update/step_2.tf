
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025151957011"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                          = "acctestIoTDPS-240119025151957011"
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
