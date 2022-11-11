
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013659249433"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221111013659249433"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}
