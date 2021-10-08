
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307081801"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211008044307081801"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_snowflake" "test" {
  name                = "acctestlssnowflake211008044307081801"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "jdbc:snowflake://account.region.snowflakecomputing.com/?user=user&db=db&warehouse=wh"
  annotations         = ["test1", "test2"]
  description         = "test description 2"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
