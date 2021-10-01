
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702336860"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211001020702336860"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211001020702336860"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestdf211001020702336860"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  pipeline_name       = azurerm_data_factory_pipeline.test.name

  annotations = ["test1", "test2", "test3"]
}
