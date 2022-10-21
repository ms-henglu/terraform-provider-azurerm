

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034211486290"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-221021034211486290"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_iothub_dps" "import" {
  name                = azurerm_iothub_dps.test.name
  resource_group_name = azurerm_iothub_dps.test.resource_group_name
  location            = azurerm_iothub_dps.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}
