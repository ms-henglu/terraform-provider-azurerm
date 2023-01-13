
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230113181015493410"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230113181015493410"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230113181015493410"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestdf230113181015493410"
  data_factory_id     = azurerm_data_factory.test.id
  pipeline_name       = azurerm_data_factory_pipeline.test.name
  description         = "test"
  pipeline_parameters = azurerm_data_factory_pipeline.test.parameters
  annotations         = ["test5"]
  frequency           = "Day"
  interval            = 5
  activated           = true
  end_time            = "2022-09-22T00:00:00Z"
  start_time          = "2022-09-21T00:00:00Z"
  time_zone           = "GMT Standard Time"
}
