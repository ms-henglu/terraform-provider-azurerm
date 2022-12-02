
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035146558430"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "13e03b2f-dc7d-4cdc-b454-fd2d12a3a137"
  name               = "acctestrd-221202035146558430"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
