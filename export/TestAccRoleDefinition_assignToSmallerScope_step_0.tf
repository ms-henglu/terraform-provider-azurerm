
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052154133028"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9e5bd459-68c9-41d7-b91f-abf38fb5ff62"
  name               = "acctestrd-220128052154133028"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
