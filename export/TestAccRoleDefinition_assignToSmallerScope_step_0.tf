
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630223417397835"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "317e1314-7ffb-4f20-a480-491a0aaac6f5"
  name               = "acctestrd-220630223417397835"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
