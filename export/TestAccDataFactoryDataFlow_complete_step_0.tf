

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220513180153994881"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsavkre9"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220513180153994881"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls220513180153994881"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}

resource "azurerm_data_factory_dataset_json" "test1" {
  name                = "acctestds1220513180153994881"
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
  name                = "acctestds2220513180153994881"
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
  name            = "acctestdf220513180153994881"
  data_factory_id = azurerm_data_factory.test.id
  description     = "description for data flow"
  annotations     = ["anno1", "anno2"]
  folder          = "folder1"

  source {
    name        = "source1"
    description = "description for source1"

    linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
      parameters = {
        "Key1" = "value1"
      }
    }

    schema_linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
      parameters = {
        "Key1" = "value1"
      }
    }
  }

  sink {
    name        = "sink1"
    description = "description for sink1"

    linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
      parameters = {
        "Key1" = "value1"
      }
    }

    schema_linked_service {
      name = azurerm_data_factory_linked_custom_service.test.name
      parameters = {
        "Key1" = "value1"
      }
    }
  }

  transformation {
    name        = "filter1"
    description = "description for filter1"
  }

  script = <<EOT
source(output(
		movie as string,
		title as string,
		genres as string,
		year as string,
		Rating as string,
		{Rotton Tomato} as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	limit: 100,
	ignoreNoFilesFound: false) ~> source1
source1 filter(toInteger(year) >= 1910 && toInteger(year) <= 2000) ~> Filter1
Filter1 sink(allowSchemaDrift: true,
	validateSchema: false,
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	saveOrder: 0,
	partitionBy('roundRobin', 3)) ~> sink1
EOT
}
