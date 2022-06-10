
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022231202713"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4945e2eb-5ac0-40cc-b063-9b69d76bd573"
  name               = "acctestrd-220610022231202713"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
