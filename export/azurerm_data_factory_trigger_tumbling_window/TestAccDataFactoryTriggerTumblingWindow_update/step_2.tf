

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119021929392614"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119021929392614"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctestdfp240119021929392614"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_tumbling_window" "dependency" {
  name            = "acctestdft2240119021929392614"
  data_factory_id = azurerm_data_factory.test.id
  frequency       = "Minute"
  interval        = 15
  start_time      = "2022-09-21T00:00:00Z"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_tumbling_window" "test" {
  name            = "acctestdft240119021929392614"
  data_factory_id = azurerm_data_factory.test.id
  start_time      = "2022-09-21T00:00:00Z"
  end_time        = "2022-09-21T08:00:00Z"
  frequency       = "Minute"
  interval        = 15
  delay           = "16:00:00"

  activated   = false
  annotations = ["test1", "test2", "test3"]
  description = "test description"

  retry {
    count    = 1
    interval = 30
  }

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
    parameters = {
      Env = "Test"
    }
  }

  // Self dependency
  trigger_dependency {
    size   = "24:00:00"
    offset = "-24:00:00"
  }

  trigger_dependency {
    size         = "06:00:00"
    offset       = "06:00:00"
    trigger_name = azurerm_data_factory_trigger_tumbling_window.dependency.name
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
