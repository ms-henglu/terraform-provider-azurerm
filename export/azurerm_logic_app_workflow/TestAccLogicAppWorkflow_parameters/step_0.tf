
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-231013043728166034"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-231013043728166034"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workflow_parameters = {
    b = jsonencode({
      type = "Bool"
    })
    str = jsonencode({
      type = "String"
    })
    int = jsonencode({
      type = "Int"
    })
    float = jsonencode({
      type = "Float"
    })
    obj = jsonencode({
      type = "Object"
    })
    array = jsonencode({
      type = "Array"
    })
    secstr = jsonencode({
      type = "SecureString"
    })
    secobj = jsonencode({
      type = "SecureObject"
    })
  }

  parameters = {
    b     = "true"
    str   = "value"
    int   = "123"
    float = "1.23"
    obj = jsonencode({
      s     = "foo"
      array = [1, 2, 3]
      obj = {
        i = 123
      }
    })
    array = jsonencode([
      1, "string", {}, []
    ])
    secstr = "value"
    secobj = jsonencode({
      foo = "foo"
    })
  }
}
