
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627131806460849"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220627131806460849"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_sql_server" "test" {
  name                = "acctestlssql220627131806460849"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"
}

resource "azurerm_data_factory_dataset_sql_server_table" "test" {
  name                = "acctestds220627131806460849"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_sql_server.test.name
}
