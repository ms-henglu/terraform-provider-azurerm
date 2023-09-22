
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053619995393"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e1633099-db00-4840-ac5c-9eedea90cb0c"
  name               = "acctestrd-230922053619995393"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
