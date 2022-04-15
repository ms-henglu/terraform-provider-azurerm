
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220415030416670140"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220415030416670140"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_mysql" "test" {
  name              = "acctestlssql220415030416670140"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}

resource "azurerm_data_factory_dataset_mysql" "test" {
  name                = "acctestds220415030416670140"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_mysql.test.name
}
