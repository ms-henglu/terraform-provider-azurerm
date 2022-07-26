
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220726014718657733"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220726014718657733"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_postgresql" "test" {
  name              = "acctestlssql220726014718657733"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "Host=example;Port=5432;Database=example;UID=example;EncryptionMethod=0;Password=example"
}

resource "azurerm_data_factory_dataset_postgresql" "test" {
  name                = "acctestds220726014718657733"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_postgresql.test.name
}
