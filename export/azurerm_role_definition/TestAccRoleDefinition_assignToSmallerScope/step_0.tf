
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113180728731386"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "be085c72-af69-4e00-8839-62de65f5eaa9"
  name               = "acctestrd-230113180728731386"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
