
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230526084957280827"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230526084957280827"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sql_server" "test" {
  name              = "acctestlssql230526084957280827"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"
}

resource "azurerm_data_factory_dataset_sql_server_table" "test" {
  name                = "acctestds230526084957280827"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.test.name
}
