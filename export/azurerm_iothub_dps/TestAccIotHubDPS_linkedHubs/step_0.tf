
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061258279916"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230922061258279916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_shared_access_policy" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name
  name                = "acctest"

  registry_read   = true
  registry_write  = true
  service_connect = true
}

resource "azurerm_iothub" "test2" {
  name                = "acctestIoTHub2-230922061258279916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_shared_access_policy" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test2.name
  name                = "acctest2"

  registry_read   = true
  registry_write  = true
  service_connect = true
}


resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-230922061258279916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string       = azurerm_iothub_shared_access_policy.test.primary_connection_string
    location                = azurerm_resource_group.test.location
    allocation_weight       = 15
    apply_allocation_policy = true
  }

  linked_hub {
    connection_string = azurerm_iothub_shared_access_policy.test2.primary_connection_string
    location          = azurerm_resource_group.test.location
  }
}
