
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923011526169765"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a393470a-e4c7-49b0-afbb-8107cb52d255"
  name               = "acctestrd-220923011526169765"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
