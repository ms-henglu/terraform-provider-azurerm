
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220204092900475169"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220204092900475169"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest220204092900475169"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestdf220204092900475169"
  data_factory_id     = azurerm_data_factory.test.id
  resource_group_name = azurerm_resource_group.test.name
  pipeline_name       = azurerm_data_factory_pipeline.test.name

  annotations = ["test1", "test2", "test3"]
  frequency   = "Month"
  interval    = 1
  activated   = true

  schedule {
    hours         = [0, 12, 23]
    minutes       = [0, 30, 59]
    days_of_month = [1, 2, 3]
    monthly {
      weekday = "Monday"
      week    = 1
    }
  }
}
