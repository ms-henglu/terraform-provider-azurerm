
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090833457266"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a2b82fb0-2e9d-4d75-b13b-72e3b5cf8a61"
  name               = "acctestrd-230609090833457266"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
