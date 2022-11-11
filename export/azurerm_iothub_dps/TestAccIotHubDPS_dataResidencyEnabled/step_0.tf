
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020618269662"
  location = "brazilsouth"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221111020618269662"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  data_residency_enabled = true

  sku {
    name     = "S1"
    capacity = "1"
  }
}
