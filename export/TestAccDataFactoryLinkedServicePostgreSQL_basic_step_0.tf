
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220114064035718208"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220114064035718208"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_postgresql" "test" {
  name                = "acctestlssql220114064035718208"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  connection_string   = "Host=example;Port=5432;Database=example;UID=example;EncryptionMethod=0;Password=example"
}
