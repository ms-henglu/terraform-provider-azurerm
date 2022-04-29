
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429075118837647"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "97f013be-9b3a-4e46-9173-49169a10b2f7"
  name               = "acctestrd-220429075118837647"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
