
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "da812937-4762-4160-b402-262a11cdb3c5"
  name               = "acctestrd-220623223047565769"
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
