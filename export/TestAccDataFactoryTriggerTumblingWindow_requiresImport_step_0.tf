

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220326010420876404"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220326010420876404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctestdfp220326010420876404"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_tumbling_window" "dependency" {
  name            = "acctestdft2220326010420876404"
  data_factory_id = azurerm_data_factory.test.id
  frequency       = "Minute"
  interval        = 15
  start_time      = "2022-09-21T00:00:00Z"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_tumbling_window" "test" {
  name            = "acctestdft220326010420876404"
  data_factory_id = azurerm_data_factory.test.id
  frequency       = "Minute"
  interval        = 15
  start_time      = "2022-09-21T00:00:00Z"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}
