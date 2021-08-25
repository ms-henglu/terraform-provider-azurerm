
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825040511084920"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "0a6a6f20-4c4a-4147-b515-6d869aa9a043"
  name               = "acctestrd-210825040511084920"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
