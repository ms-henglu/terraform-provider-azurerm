


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240112224333481440"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240112224333481440"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctestdfp240112224333481440"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_tumbling_window" "dependency" {
  name            = "acctestdft2240112224333481440"
  data_factory_id = azurerm_data_factory.test.id
  frequency       = "Minute"
  interval        = 15
  start_time      = "2022-09-21T00:00:00Z"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_tumbling_window" "test" {
  name            = "acctestdft240112224333481440"
  data_factory_id = azurerm_data_factory.test.id
  frequency       = "Minute"
  interval        = 15
  start_time      = "2022-09-21T00:00:00Z"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_tumbling_window" "import" {
  name            = azurerm_data_factory_trigger_tumbling_window.test.name
  data_factory_id = azurerm_data_factory_trigger_tumbling_window.test.data_factory_id
  frequency       = azurerm_data_factory_trigger_tumbling_window.test.frequency
  interval        = azurerm_data_factory_trigger_tumbling_window.test.interval
  start_time      = azurerm_data_factory_trigger_tumbling_window.test.start_time

  dynamic "pipeline" {
    for_each = azurerm_data_factory_trigger_tumbling_window.test.pipeline
    content {
      name = pipeline.value.name
    }
  }
}
