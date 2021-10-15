
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014725152936"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-211015014725152936"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string       = "HostName=test.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=booo"
    location                = azurerm_resource_group.test.location
    allocation_weight       = 15
    apply_allocation_policy = true
  }

  linked_hub {
    connection_string = "HostName=test2.azure-devices.net;SharedAccessKeyName=iothubowner2;SharedAccessKey=key2"
    location          = azurerm_resource_group.test.location
  }
}
