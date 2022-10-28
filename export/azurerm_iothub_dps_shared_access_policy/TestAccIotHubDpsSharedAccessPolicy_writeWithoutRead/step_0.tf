
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172252041141"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221028172252041141"
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
  registration_write  = true
}
