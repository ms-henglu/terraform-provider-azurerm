
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221124181538944147"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221124181538944147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name              = "acctestlscosmosdb221124181538944147"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}
