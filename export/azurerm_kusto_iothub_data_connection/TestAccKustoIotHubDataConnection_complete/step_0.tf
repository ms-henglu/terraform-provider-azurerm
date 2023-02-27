

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175605655707"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc88l8m"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-230227175605655707"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230227175605655707"
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
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name

  registry_read = true
}

resource "azurerm_iothub_consumer_group" "test" {
  name                   = "acctest"
  iothub_name            = azurerm_iothub.test.name
  eventhub_endpoint_name = "events"
  resource_group_name    = azurerm_resource_group.test.name
}


resource "azurerm_kusto_iothub_data_connection" "test" {
  name                = "acctestkedc-230227175605655707"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
  database_name       = azurerm_kusto_database.test.name

  iothub_id                 = azurerm_iothub.test.id
  consumer_group            = azurerm_iothub_consumer_group.test.name
  shared_access_policy_name = azurerm_iothub_shared_access_policy.test.name
  event_system_properties   = ["message-id", "sequence-number", "to"]
  mapping_rule_name         = "Json_Mapping"
  data_format               = "MULTIJSON"
  database_routing_type     = "Multi"
}
