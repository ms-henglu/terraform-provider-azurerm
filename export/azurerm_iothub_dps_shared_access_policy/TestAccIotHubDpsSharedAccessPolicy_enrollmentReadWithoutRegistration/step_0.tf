
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034211481919"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221021034211481919"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_dps_shared_access_policy" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_dps_name     = azurerm_iothub_dps.test.name
  name                = "acctest"
  enrollment_read     = true
}
