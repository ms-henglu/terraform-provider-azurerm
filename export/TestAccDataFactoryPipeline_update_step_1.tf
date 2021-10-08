
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211008044307090831"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2211008044307090831"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                           = "acctest211008044307090831"
  resource_group_name            = azurerm_resource_group.test.name
  data_factory_name              = azurerm_data_factory.test.name
  annotations                    = ["test1", "test2"]
  concurrency                    = 30
  description                    = "test description2"
  moniter_metrics_after_duration = "12:23:34"
  folder                         = "test-folder"

  parameters = {
    test  = "testparameter"
    test2 = "testparameter2"
  }

  variables = {
    foo = "test1"
    bar = "test2"
    baz = "test3"
  }
}
