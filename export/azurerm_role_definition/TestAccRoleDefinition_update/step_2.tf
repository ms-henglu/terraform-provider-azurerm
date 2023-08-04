
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "97ac4a80-32d2-42f9-89ac-537a4afffbcf"
  name               = "acctestrd-230804025429826933"
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
