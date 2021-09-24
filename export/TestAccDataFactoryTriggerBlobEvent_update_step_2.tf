

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210924004140113792"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210924004140113792"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest210924004140113792"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

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
  name                     = "acctestsav6l4l"
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
  name                 = "acctestsalinkv6l4l"
  resource_group_name  = azurerm_resource_group.test.name
  data_factory_name    = azurerm_data_factory.test.name
  use_managed_identity = true

  service_endpoint = azurerm_storage_account.test.primary_blob_endpoint
}


resource "azurerm_data_factory_trigger_blob_event" "test" {
  name                  = "acctestdf210924004140113792"
  data_factory_id       = azurerm_data_factory.test.id
  storage_account_id    = azurerm_storage_account.test.id
  events                = ["Microsoft.Storage.BlobCreated", "Microsoft.Storage.BlobDeleted"]
  blob_path_begins_with = "/${azurerm_storage_container.test.name}/blobs/"
  blob_path_ends_with   = ".txt"
  ignore_empty_blobs    = true
  activated             = true

  annotations = ["test1", "test2", "test3"]
  description = "test description"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
    parameters = {
      Env = "Test"
    }
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
