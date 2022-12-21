
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221221204215461683"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2221221204215461683"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                           = "acctest221221204215461683"
  data_factory_id                = azurerm_data_factory.test.id
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
