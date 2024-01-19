

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025218620028"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestwr2lh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcwr2lh"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240119025218620028"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240119025218620028"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240119025218620028"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-240119025218620028"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_kusto_eventhub_data_connection" "test" {
  name                = "acctestkedc-240119025218620028"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
  database_name       = azurerm_kusto_database.test.name

  eventhub_id    = azurerm_eventhub.test.id
  consumer_group = azurerm_eventhub_consumer_group.test.name

  mapping_rule_name = "Json_Mapping"
  data_format       = "MULTIJSON"
}
