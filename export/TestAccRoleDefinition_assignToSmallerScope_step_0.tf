
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001223650449199"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "438f6dad-98fe-4f32-be77-4c4f18abac47"
  name               = "acctestrd-211001223650449199"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
