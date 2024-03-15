

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824813414"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdf4b1en"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240315122824813414"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls240315122824813414"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}


resource "azurerm_data_factory_custom_dataset" "test" {
  name            = "acctestds240315122824813414"
  data_factory_id = azurerm_data_factory.test.id
  type            = "Avro"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.test.name
  }

  type_properties_json = <<JSON
{
  "location": {
    "fileName":".avro",
    "folderPath": "foo",
    "type":"AzureBlobStorageLocation"
  },
  "avroCompressionCodec": "deflate",
  "avroCompressionLevel": 4
}
JSON

  schema_json = <<JSON
{
  "type": "record",
  "namespace": "com.example",
  "name": "test",
  "fields": [
    {
      "name": "first",
      "type": "string"
    },
    {
      "name": "last",
      "type": "int"
    },
    {
      "name": "Hobby",
      "type": {
        "type": "array",
        "items": "string"
      }
    }
  ]
}
JSON
}
