
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "246ce1b1-5633-4f79-8574-2a417774f04f"
  name               = "acctestrd-210924010706672358"
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
