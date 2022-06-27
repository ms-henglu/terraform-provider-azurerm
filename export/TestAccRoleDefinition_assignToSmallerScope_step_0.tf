
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627130801187988"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "8537f7ea-9e24-482b-847b-38e7b54186d3"
  name               = "acctestrd-220627130801187988"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
