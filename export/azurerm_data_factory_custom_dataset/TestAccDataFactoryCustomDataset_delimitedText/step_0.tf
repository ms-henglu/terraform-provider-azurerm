

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301665727"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfat1wj"
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
  name                = "acctestdf230915023301665727"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls230915023301665727"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}


resource "azurerm_data_factory_custom_dataset" "test" {
  name            = "acctestds230915023301665727"
  data_factory_id = azurerm_data_factory.test.id
  type            = "DelimitedText"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.test.name
  }

  type_properties_json = <<JSON
{
  "location": {
    "container":"test",
    "fileName":"foo.txt",
    "folderPath": "foo/bar/",
    "type":"AzureBlobStorageLocation"
  },
  "columnDelimiter": "\n",
  "rowDelimiter": "\t",
  "encodingName": "UTF-8",
  "compressionCodec": "bzip2",
  "compressionLevel": "Farest",
  "quoteChar": "",
  "escapeChar": "",
  "firstRowAsHeader": false,
  "nullValue": ""
}
JSON

  schema_json = <<JSON
[
  {
    "name": "col1",
    "type": "INT_32"
  },
  {
    "name": "col2",
    "type": "Decimal",
    "precision": "38",
    "scale": "2"
  }
]
JSON
}
