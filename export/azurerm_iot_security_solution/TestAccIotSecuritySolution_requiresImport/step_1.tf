


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-security-230915024134833543"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230915024134833543"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_iot_security_solution" "test" {
  name                = "acctest-Iot-Security-Solution-230915024134833543"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "Iot Security Solution"
  iothub_ids          = [azurerm_iothub.test.id]
}


resource "azurerm_iot_security_solution" "import" {
  name                = azurerm_iot_security_solution.test.name
  resource_group_name = azurerm_iot_security_solution.test.resource_group_name
  location            = azurerm_iot_security_solution.test.location
  display_name        = azurerm_iot_security_solution.test.display_name
  iothub_ids          = [azurerm_iothub.test.id]
}
