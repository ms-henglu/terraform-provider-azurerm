
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627122411308678"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cc8f1ed8-eb7a-4bc8-97e1-1a92f5f7bbfa"
  name               = "acctestrd-220627122411308678"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
