
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307082961"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211008044307082961"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_mysql" "test" {
  name                = "acctestlssql211008044307082961"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}
