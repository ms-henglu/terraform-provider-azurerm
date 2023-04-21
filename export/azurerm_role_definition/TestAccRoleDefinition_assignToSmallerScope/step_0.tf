
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021706839369"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2528b9d1-8bfc-47c2-9e8c-40a2d5245240"
  name               = "acctestrd-230421021706839369"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
