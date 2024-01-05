
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060258078540"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "8c001055-229d-4f89-a4f3-a3e953c42668"
  name               = "acctestrd-240105060258078540"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
