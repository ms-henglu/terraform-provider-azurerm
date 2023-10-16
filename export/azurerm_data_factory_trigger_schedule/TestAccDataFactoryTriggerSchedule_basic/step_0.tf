
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759702691"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759702691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest231016033759702691"
  data_factory_id = azurerm_data_factory.test.id

  parameters = {
    test = "testparameter"
  }
}

resource "azurerm_data_factory_trigger_schedule" "test" {
  name            = "acctestdf231016033759702691"
  data_factory_id = azurerm_data_factory.test.id
  pipeline_name   = azurerm_data_factory_pipeline.test.name

  annotations = ["test1", "test2", "test3"]
}
