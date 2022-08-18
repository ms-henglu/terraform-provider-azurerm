
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818234847428373"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cb914968-307c-47cc-beb9-43c0bba18c7d"
  name               = "acctestrd-220818234847428373"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
