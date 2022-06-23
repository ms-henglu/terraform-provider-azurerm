
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623233252675264"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "268a55ae-9fa0-486f-8c47-761cd5f72286"
  name               = "acctestrd-220623233252675264"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
