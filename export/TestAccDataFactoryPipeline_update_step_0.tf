
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220121044418499058"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2220121044418499058"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest220121044418499058"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    test = "testparameter"
  }

  variables = {
    foo = "test1"
    bar = "test2"
  }
}
