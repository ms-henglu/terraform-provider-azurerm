
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759672013"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759672013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name                 = "acctestlsazsql231016033759672013"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true
  connection_string    = "Integrated Security=False;Data Source=test.database.windows.net;Initial Catalog=test"
}

resource "azurerm_data_factory_dataset_azure_sql_table" "test" {
  name              = "acctestds231016033759672013"
  data_factory_id   = azurerm_data_factory.test.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.test.id
}
