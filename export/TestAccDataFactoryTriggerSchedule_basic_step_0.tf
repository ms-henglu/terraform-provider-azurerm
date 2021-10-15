
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127485752"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127485752"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211015014127485752"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestdf211015014127485752"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  pipeline_name       = azurerm_data_factory_pipeline.test.name

  annotations = ["test1", "test2", "test3"]
}
