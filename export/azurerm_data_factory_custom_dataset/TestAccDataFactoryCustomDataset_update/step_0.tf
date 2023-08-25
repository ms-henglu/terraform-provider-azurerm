

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423925010"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfryw3m"
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
  name                = "acctestdf230825024423925010"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls230825024423925010"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}


resource "azurerm_data_factory_custom_dataset" "test" {
  name            = "acctestds230825024423925010"
  data_factory_id = azurerm_data_factory.test.id
  type            = "Json"

  linked_service {
    name = azurerm_data_factory_linked_custom_service.test.name
  }

  type_properties_json = <<JSON
{
  "location": {
    "container": "${azurerm_storage_container.test.name}",
    "type": "AzureBlobStorageLocation"
  }
}
JSON
}
