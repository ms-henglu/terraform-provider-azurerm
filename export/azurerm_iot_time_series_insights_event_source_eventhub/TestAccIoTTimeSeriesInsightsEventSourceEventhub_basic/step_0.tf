
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-240105060935921439"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240105060935921439"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240105060935921439"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-240105060935921439"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-240105060935921439"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = false
  manage = false
}

resource "azurerm_storage_account" "storage" {
  name                     = "acctestsatsiby9b2"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_iot_time_series_insights_gen2_environment" "test" {
  name                = "acctest_tsie240105060935921439"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "L1"
  id_properties       = ["id"]

  storage {
    name = azurerm_storage_account.storage.name
    key  = azurerm_storage_account.storage.primary_access_key
  }
}

resource "azurerm_iot_time_series_insights_event_source_eventhub" "test" {
  name                     = "acctest_tsiesi240105060935921439"
  location                 = azurerm_resource_group.test.location
  environment_id           = azurerm_iot_time_series_insights_gen2_environment.test.id
  eventhub_name            = azurerm_eventhub.test.name
  namespace_name           = azurerm_eventhub_namespace.test.name
  shared_access_key        = azurerm_eventhub_authorization_rule.test.primary_key
  shared_access_key_name   = azurerm_eventhub_authorization_rule.test.name
  consumer_group_name      = azurerm_eventhub_consumer_group.test.name
  event_source_resource_id = azurerm_eventhub.test.id
}
