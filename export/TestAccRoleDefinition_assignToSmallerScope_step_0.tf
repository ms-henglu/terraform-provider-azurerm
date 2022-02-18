
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218070432556720"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "47d86f1e-d34e-4472-b033-403cb74979ea"
  name               = "acctestrd-220218070432556720"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
