
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172252044526"
  location = "brazilsouth"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221028172252044526"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  data_residency_enabled = true

  sku {
    name     = "S1"
    capacity = "1"
  }
}
