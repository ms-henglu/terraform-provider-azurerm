
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702324759"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211001020702324759"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_snowflake" "test" {
  name                = "acctestlssnowflake211001020702324759"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = "jdbc:snowflake://account.region.snowflakecomputing.com/?user=user&db=db&warehouse=wh"
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
