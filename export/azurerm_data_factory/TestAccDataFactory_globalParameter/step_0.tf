
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230721014936677837"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230721014936677837"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  global_parameter {
    name  = "intVal"
    type  = "Int"
    value = "3"
  }

  global_parameter {
    name  = "stringVal"
    type  = "String"
    value = "foo"
  }

  global_parameter {
    name  = "boolVal"
    type  = "Bool"
    value = "true"
  }

  global_parameter {
    name  = "floatVal"
    type  = "Float"
    value = "3.0"
  }

  global_parameter {
    name  = "arrayVal"
    type  = "Array"
    value = jsonencode(["a", "b", "c"])
  }

  global_parameter {
    name  = "objectVal"
    type  = "Object"
    value = jsonencode({ name : "value" })
  }
}
