
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064400659459"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "ac6a0057-366c-4692-8ed4-1a829df8027a"
  name               = "acctestrd-230929064400659459"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
