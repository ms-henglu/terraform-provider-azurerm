

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034116210279"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest68pnn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc68pnn"
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
  name                = "acctestkd-231016034116210279"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc68pnn"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-231016034116210279"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-231016034116210279"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-231016034116210279"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name                  = "acctest-eg-231016034116210279"
  scope                 = azurerm_storage_account.test.id
  eventhub_endpoint_id  = azurerm_eventhub.test.id
  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobRenamed"]

  retry_policy {
    event_time_to_live    = 144
    max_delivery_attempts = 10
  }
}


resource "azurerm_kusto_eventgrid_data_connection" "test" {
  name                         = "acctestkrgdc-231016034116210279"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  cluster_name                 = azurerm_kusto_cluster.test.name
  database_name                = azurerm_kusto_database.test.name
  storage_account_id           = azurerm_storage_account.test.id
  eventhub_id                  = azurerm_eventhub.test.id
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.test.name

  depends_on = [azurerm_eventgrid_event_subscription.test]
}
