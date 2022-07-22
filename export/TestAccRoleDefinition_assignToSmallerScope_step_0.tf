
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722034834689194"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "551f0473-dbfa-4f0f-859d-712635a954d9"
  name               = "acctestrd-220722034834689194"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
