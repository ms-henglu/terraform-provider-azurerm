
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010553191644"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2230512010553191644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230512010553191644"
  data_factory_id = azurerm_data_factory.test.id
  variables = {
    "bob" = "item1"
  }
  activities_json = <<JSON
[
  {
    "name": "Append variable1",
    "type": "AppendVariable",
    "dependsOn": [],
    "userProperties": [],
    "typeProperties": {
      "variableName": "bob",
      "value": "something"
    }
  }
]
JSON
}
