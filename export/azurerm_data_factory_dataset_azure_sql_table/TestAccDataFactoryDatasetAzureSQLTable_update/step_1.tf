
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824820658"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240315122824820658"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlsazsql240315122824820658"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true
  connection_string    = "Integrated Security=False;Data Source=test.database.windows.net;Initial Catalog=test"
}

resource "azurerm_data_factory_dataset_azure_sql_table" "test" {
  name              = "acctestds240315122824820658"
  data_factory_id   = azurerm_data_factory.test.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.test.id

  description = "test description 2"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }

  schema_column {
    name        = "test1"
    type        = "Byte"
    description = "description"
  }

  schema_column {
    name        = "test2"
    type        = "Byte"
    description = "description"
  }
}
