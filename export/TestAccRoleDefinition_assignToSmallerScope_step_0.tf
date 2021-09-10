
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021112258654"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1978ef5b-8e4f-4e6d-b9df-af3571f92563"
  name               = "acctestrd-210910021112258654"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
