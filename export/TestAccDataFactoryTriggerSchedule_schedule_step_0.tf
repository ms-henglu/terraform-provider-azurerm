
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211119050737606877"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211119050737606877"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211119050737606877"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestdf211119050737606877"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  pipeline_name       = azurerm_data_factory_pipeline.test.name

  annotations = ["test1", "test2", "test3"]

  schedule {
    days_of_month = [1, 2, 3]
    days_of_week  = ["Monday", "Tuesday"]
    hours         = [0, 12, 24]
    minutes       = [0, 30, 60]
    monthly {
      weekday = "Monday"
      week    = 1
    }
  }
}
