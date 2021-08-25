

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "6a0c0c3b-909e-49e8-8518-e5ed0bb3ff36"
  name               = "acctestrd-210825044513742229"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}


resource "azurerm_role_definition" "import" {
  role_definition_id = azurerm_role_definition.test.role_definition_id
  name               = azurerm_role_definition.test.name
  scope              = azurerm_role_definition.test.scope

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}
