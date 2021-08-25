
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044506677629"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9914658e-91a5-4d6b-93ce-c37339ab7544"
  name               = "acctestrd-210825044506677629"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
