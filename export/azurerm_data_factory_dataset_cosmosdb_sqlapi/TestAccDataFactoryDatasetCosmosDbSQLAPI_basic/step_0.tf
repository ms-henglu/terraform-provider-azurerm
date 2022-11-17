
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221117230800967022"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221117230800967022"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_cosmosdb" "test" {
  name              = "acctestlscosmosdb221117230800967022"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
}

resource "azurerm_data_factory_dataset_cosmosdb_sqlapi" "test" {
  name                = "acctestds221117230800967022"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_cosmosdb.test.name

  collection_name = "Foo"

}
