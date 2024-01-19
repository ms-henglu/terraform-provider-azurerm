
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025151957415"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-240119025151957415"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}
