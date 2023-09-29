


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230929064753309766"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230929064753309766"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230929064753309766"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }

  variables = {
    test = "testvariable"
  }

  activities_json = <<JSON
[
    {
        "name": "Append variable",
        "type": "AppendVariable",
        "dependsOn": [],
        "userProperties": [],
        "typeProperties": {
            "variableName": "test",
            "value": "something"
        }
    }
]
  JSON
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalvfxo"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test-sc"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "blob_link" {
  name                 = "acctestsalinklvfxo"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true

  service_endpoint = azurerm_storage_account.test.primary_blob_endpoint
}


resource "azurerm_data_factory_trigger_blob_event" "test" {
  name                  = "acctestdf230929064753309766"
  data_factory_id       = azurerm_data_factory.test.id
  storage_account_id    = azurerm_storage_account.test.id
  events                = ["Microsoft.Storage.BlobCreated"]
  blob_path_begins_with = "/abc/blobs"
  activated             = false

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_blob_event" "import" {
  name                  = azurerm_data_factory_trigger_blob_event.test.name
  data_factory_id       = azurerm_data_factory_trigger_blob_event.test.data_factory_id
  storage_account_id    = azurerm_data_factory_trigger_blob_event.test.storage_account_id
  events                = azurerm_data_factory_trigger_blob_event.test.events
  blob_path_begins_with = azurerm_data_factory_trigger_blob_event.test.blob_path_begins_with

  dynamic "pipeline" {
    for_each = azurerm_data_factory_trigger_blob_event.test.pipeline
    content {
      name = pipeline.value.name
    }
  }
}
