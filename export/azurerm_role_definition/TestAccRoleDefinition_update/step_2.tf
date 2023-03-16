
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "df1d045b-f51e-44fd-b5aa-398b98b5a6c4"
  name               = "acctestrd-230316221038390327"
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
