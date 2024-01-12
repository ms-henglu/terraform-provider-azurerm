
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033853118879"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9f1ad1ac-b1d2-4bef-b107-77013a4f46f9"
  name               = "acctestrd-240112033853118879"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
