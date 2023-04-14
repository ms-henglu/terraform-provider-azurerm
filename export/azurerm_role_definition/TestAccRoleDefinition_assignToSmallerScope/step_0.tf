
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020758131832"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "8989bff1-3596-43cb-96b5-fa0d58e6bb3f"
  name               = "acctestrd-230414020758131832"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
