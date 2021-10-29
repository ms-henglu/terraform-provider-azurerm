
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015234975318"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e035a132-4839-4c8b-bee7-8f0f3fdac6f2"
  name               = "acctestrd-211029015234975318"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
