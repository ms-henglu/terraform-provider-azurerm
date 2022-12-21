
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204411465128"
  location = "brazilsouth"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221221204411465128"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  data_residency_enabled = true

  sku {
    name     = "S1"
    capacity = "1"
  }
}
