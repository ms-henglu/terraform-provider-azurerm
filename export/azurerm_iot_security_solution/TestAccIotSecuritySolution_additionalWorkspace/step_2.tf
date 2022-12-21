

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-security-221221204804066730"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221221204804066730"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-law-221221204804066730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "test2" {
  name                = "acctest-law2-221221204804066730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_iot_security_solution" "test" {
  name                = "acctest-Iot-Security-Solution-221221204804066730"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "Iot Security Solution"
  iothub_ids          = [azurerm_iothub.test.id]

  additional_workspace {
    data_types   = ["Alerts", "RawEvents"]
    workspace_id = azurerm_log_analytics_workspace.test2.id
  }
}
