

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-security-211203014354518788"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-211203014354518788"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-law-211203014354518788"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "test2" {
  name                = "acctest-law2-211203014354518788"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_iot_security_solution" "test" {
  name                = "acctest-Iot-Security-Solution-211203014354518788"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "Iot Security Solution"
  iothub_ids          = [azurerm_iothub.test.id]

  additional_workspace {
    data_types   = ["Alerts", "RawEvents"]
    workspace_id = azurerm_log_analytics_workspace.test2.id
  }
}
