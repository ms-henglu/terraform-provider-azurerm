
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013108644826"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b30a83fe-b7d5-47f7-8d8b-e726595debc4"
  name               = "acctestrd-221111013108644826"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
