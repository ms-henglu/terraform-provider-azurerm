
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122327839140"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "180bea5b-1e5c-4a58-8076-77bee4bce9f1"
  name               = "acctestrd-240315122327839140"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
