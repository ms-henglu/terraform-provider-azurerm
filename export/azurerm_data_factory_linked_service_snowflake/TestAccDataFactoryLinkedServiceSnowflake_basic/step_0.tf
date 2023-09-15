
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301719342"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230915023301719342"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_snowflake" "test" {
  name              = "acctestlssnowflake230915023301719342"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "jdbc:snowflake://account.region.snowflakecomputing.com/?user=user&db=db&warehouse=wh"
  annotations       = ["test1", "test2", "test3"]
  description       = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
