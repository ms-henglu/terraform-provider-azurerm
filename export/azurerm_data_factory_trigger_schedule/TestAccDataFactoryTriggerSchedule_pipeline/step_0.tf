
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423963927"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230825024423963927"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test1" {
  name            = "acctest230825024423963927"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter1"
  }
}

resource "azurerm_data_factory_pipeline" "test2" {
  name            = "acctests230825024423963927"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter2"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name            = "acctestdf230825024423963927"
  data_factory_id = azurerm_data_factory.test.id

  pipeline {
    name       = azurerm_data_factory_pipeline.test1.name
    parameters = azurerm_data_factory_pipeline.test1.parameters
  }

  pipeline {
    name       = azurerm_data_factory_pipeline.test2.name
    parameters = azurerm_data_factory_pipeline.test2.parameters
  }

  annotations = ["test1", "test2", "test3"]
}
