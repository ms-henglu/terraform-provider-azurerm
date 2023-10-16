


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759679645"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalyo7i"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759679645"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls231016033759679645"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}

resource "azurerm_data_factory_dataset_json" "test1" {
  name                = "acctestds1231016033759679645"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_custom_service.test.name

  azure_blob_storage_location {
    container = "container"
    path      = "foo/bar/"
    filename  = "foo.txt"
  }

  encoding = "UTF-8"
}

resource "azurerm_data_factory_dataset_json" "test2" {
  name                = "acctestds2231016033759679645"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_custom_service.test.name

  azure_blob_storage_location {
    container = "container"
    path      = "foo/bar/"
    filename  = "bar.txt"
  }

  encoding = "UTF-8"
}


resource "azurerm_data_factory_data_flow" "test" {
  name            = "acctestdf231016033759679645"
  data_factory_id = azurerm_data_factory.test.id

  source {
    name = "source1"

    linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
    }
  }

  sink {
    name = "sink1"

    linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
    }
  }

  script = <<EOT
source(
  allowSchemaDrift: true, 
  validateSchema: false, 
  limit: 100, 
  ignoreNoFilesFound: false, 
  documentForm: 'documentPerLine') ~> source1 
source1 sink(
  allowSchemaDrift: true, 
  validateSchema: false, 
  skipDuplicateMapInputs: true, 
  skipDuplicateMapOutputs: true) ~> sink1
EOT
}


resource "azurerm_data_factory_data_flow" "import" {
  name            = azurerm_data_factory_data_flow.test.name
  data_factory_id = azurerm_data_factory_data_flow.test.data_factory_id
  script          = azurerm_data_factory_data_flow.test.script
  source {
    name = azurerm_data_factory_data_flow.test.source.0.name
    linked_service {
      name = azurerm_data_factory_data_flow.test.source.0.linked_service.0.name
    }
  }

  sink {
    name = azurerm_data_factory_data_flow.test.sink.0.name
    linked_service {
      name = azurerm_data_factory_data_flow.test.sink.0.linked_service.0.name
    }
  }
}
