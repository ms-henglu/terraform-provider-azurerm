
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513022916933883"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "8117ed22-6e37-4c15-9bf6-a197de8005eb"
  name               = "acctestrd-220513022916933883"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
