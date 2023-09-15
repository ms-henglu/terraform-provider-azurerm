
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022905260494"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "35d6552b-f4c3-4529-bcbf-f54e01ce3f39"
  name               = "acctestrd-230915022905260494"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
