
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759709420"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2231016033759709420"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest231016033759709420"
  data_factory_id = azurerm_data_factory.test.id
  annotations     = ["test1", "test2", "test3"]
  description     = "test description"

  parameters = {
    test = "testparameter"
  }

  variables = {
    foo = "test1"
    bar = "test2"
  }
}
