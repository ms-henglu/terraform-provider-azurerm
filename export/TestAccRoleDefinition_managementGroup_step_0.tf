
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c7a4cc7c-9ca8-4ce4-9915-51b89e135a80"
  name               = "acctestrd-220429075118836576"
  scope              = azurerm_management_group.test.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_management_group.test.id,
    data.azurerm_subscription.primary.id,
  ]
}
