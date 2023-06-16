
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "70775dcb-535a-42ef-832a-77a7c348e3dc"
  name               = "acctestrd-230616074256044076"
  scope              = data.azurerm_subscription.primary.id
  description        = "Acceptance Test Role Definition Updated"

  permissions {
    actions     = ["*"]
    not_actions = ["Microsoft.Authorization/*/read"]
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}
