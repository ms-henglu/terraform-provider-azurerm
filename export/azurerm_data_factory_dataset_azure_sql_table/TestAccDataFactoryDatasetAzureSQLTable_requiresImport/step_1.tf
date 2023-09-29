

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230929064753230533"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230929064753230533"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlsazsql230929064753230533"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true
  connection_string    = "Integrated Security=False;Data Source=test.database.windows.net;Initial Catalog=test"
}

resource "azurerm_data_factory_dataset_azure_sql_table" "test" {
  name              = "acctestds230929064753230533"
  data_factory_id   = azurerm_data_factory.test.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.test.id
}


resource "azurerm_data_factory_dataset_azure_sql_table" "import" {
  name              = azurerm_data_factory_dataset_azure_sql_table.test.name
  data_factory_id   = azurerm_data_factory_dataset_azure_sql_table.test.data_factory_id
  linked_service_id = azurerm_data_factory_dataset_azure_sql_table.test.linked_service_id
}
