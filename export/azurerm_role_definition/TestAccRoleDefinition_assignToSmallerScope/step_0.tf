
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054241036833"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2e642473-0d70-45d4-afd6-1010d0e8d7f6"
  name               = "acctestrd-230120054241036833"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
