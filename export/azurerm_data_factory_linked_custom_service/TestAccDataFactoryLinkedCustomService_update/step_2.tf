

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231013043329238188"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231013043329238188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsak00il"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_factory_integration_runtime_managed" "test" {
  name            = "acctest-irm231013043329238188"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location

  node_size                        = "Standard_D8_v3"
  number_of_nodes                  = 2
  max_parallel_executions_per_node = 8
  edition                          = "Standard"
  license_type                     = "LicenseIncluded"
}


resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls231013043329238188"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  description          = "test description"
  type_properties_json = <<JSON
{
  "connectionString":"${azurerm_storage_account.test.primary_connection_string}"
}
JSON

  integration_runtime {
    name = azurerm_data_factory_integration_runtime_managed.test.name
    parameters = {
      "Key" : "value"
    }
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }

  annotations = [
    "test1",
    "test2",
    "test3"
  ]

  parameters = {
    "foo" : "bar"
    "Env" : "Test"
  }
}
