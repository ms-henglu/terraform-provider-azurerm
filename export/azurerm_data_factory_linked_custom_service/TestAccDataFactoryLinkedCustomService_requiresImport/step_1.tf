


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230804025818546841"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230804025818546841"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaxiyyb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_factory_integration_runtime_managed" "test" {
  name            = "acctest-irm230804025818546841"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location

  node_size                        = "Standard_D8_v3"
  number_of_nodes                  = 2
  max_parallel_executions_per_node = 8
  edition                          = "Standard"
  license_type                     = "LicenseIncluded"
}


resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls230804025818546841"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}


resource "azurerm_data_factory_linked_custom_service" "import" {
  name                 = azurerm_data_factory_linked_custom_service.test.name
  data_factory_id      = azurerm_data_factory_linked_custom_service.test.data_factory_id
  type                 = azurerm_data_factory_linked_custom_service.test.type
  type_properties_json = azurerm_data_factory_linked_custom_service.test.type_properties_json
}
