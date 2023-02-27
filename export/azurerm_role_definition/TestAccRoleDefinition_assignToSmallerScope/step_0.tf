
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175117437566"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7d5802ff-8341-4b61-9268-78e3b3356254"
  name               = "acctestrd-230227175117437566"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
