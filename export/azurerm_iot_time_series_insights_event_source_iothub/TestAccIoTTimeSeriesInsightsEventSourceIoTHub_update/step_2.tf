
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-240105060935920521"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240105060935920521"
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

resource "azurerm_iothub_consumer_group" "test" {
  name                   = "test"
  iothub_name            = azurerm_iothub.test.name
  eventhub_endpoint_name = "events"
  resource_group_name    = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "storage" {
  name                     = "acctestsatsi4tqwv"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_iot_time_series_insights_gen2_environment" "test" {
  name                = "acctest_tsie240105060935920521"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "L1"
  id_properties       = ["id"]

  storage {
    name = azurerm_storage_account.storage.name
    key  = azurerm_storage_account.storage.primary_access_key
  }
}

resource "azurerm_iot_time_series_insights_event_source_iothub" "test" {
  name                     = "acctest_tsiesi240105060935920521"
  location                 = azurerm_resource_group.test.location
  environment_id           = azurerm_iot_time_series_insights_gen2_environment.test.id
  iothub_name              = azurerm_iothub.test.name
  shared_access_key        = azurerm_iothub.test.shared_access_policy.0.primary_key
  shared_access_key_name   = azurerm_iothub.test.shared_access_policy.0.key_name
  consumer_group_name      = azurerm_iothub_consumer_group.test.name
  event_source_resource_id = azurerm_iothub.test.id
  timestamp_property_name  = "test"

  tags = {
    purpose = "testing"
  }
}
