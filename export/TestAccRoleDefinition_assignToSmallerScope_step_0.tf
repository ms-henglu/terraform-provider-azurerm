
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075203947970"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7f0cdc37-01a4-4370-8ab9-fa0d5e8b04a9"
  name               = "acctestrd-210928075203947970"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
