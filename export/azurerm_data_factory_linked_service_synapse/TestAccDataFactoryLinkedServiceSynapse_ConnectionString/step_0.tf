
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423959812"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230825024423959812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_synapse" "test" {
  name            = "linksynapse"
  data_factory_id = azurerm_data_factory.test.id

  connection_string = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"

  annotations = ["test1", "test2", "test3"]
  description = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
