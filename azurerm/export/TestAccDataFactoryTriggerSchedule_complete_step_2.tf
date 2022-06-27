
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datafactory-220627134431668197"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220627134431668197"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest220627134431668197"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name                = "acctestDFTS220627134431668197"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
  pipeline_name       = azurerm_data_factory_pipeline.test.name

  pipeline_parameters = azurerm_data_factory_pipeline.test.parameters
  annotations         = ["test5"]
  frequency           = "Day"
  interval            = 5
  end_time            = "2022-06-27T20:44:00Z"
}
