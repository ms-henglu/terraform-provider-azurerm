
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759705334"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759705334"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_snowflake" "test" {
  name              = "acctestlssnowflake231016033759705334"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = "jdbc:snowflake://account.region.snowflakecomputing.com/?user=user&db=db&warehouse=wh"
  annotations       = ["test1", "test2"]
  description       = "test description 2"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
