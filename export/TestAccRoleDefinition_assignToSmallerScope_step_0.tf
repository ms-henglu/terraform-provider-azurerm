
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105025642796314"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9573e0a0-5acd-4188-b3e8-93446ff580c6"
  name               = "acctestrd-211105025642796314"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
