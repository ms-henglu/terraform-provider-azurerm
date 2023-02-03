
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203062850606555"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7865dcb8-3575-48d6-9d7e-cbe7692b452e"
  name               = "acctestrd-230203062850606555"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
