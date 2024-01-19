
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d3a6693c-887f-437e-9992-a921d4cbaaa5"
  name               = "acctestrd-240119024515592507"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
