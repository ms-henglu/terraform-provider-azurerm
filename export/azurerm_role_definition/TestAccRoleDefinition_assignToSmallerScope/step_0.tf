
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032656072220"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "41494142-c59d-45de-b0dd-d60c4b977dd6"
  name               = "acctestrd-230630032656072220"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
