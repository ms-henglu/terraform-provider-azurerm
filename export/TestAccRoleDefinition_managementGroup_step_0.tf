
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d5c2aa53-8da7-48f6-86f6-8e66e7171b62"
  name               = "acctestrd-211013071533250105"
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
