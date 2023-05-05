
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045852937097"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "aeb75d99-8d42-4575-99f1-5d3b05308c36"
  name               = "acctestrd-230505045852937097"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
