

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-security-231016034644395041"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231016034644395041"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_iot_security_solution" "test" {
  name                = "acctest-Iot-Security-Solution-231016034644395041"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "Iot Security Solution"
  iothub_ids          = [azurerm_iothub.test.id]
}
