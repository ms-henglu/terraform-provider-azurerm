
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142938995110"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "3ca5ac9c-b91b-4c4f-bda5-f9855139bd26"
  name               = "acctestrd-230810142938995110"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
