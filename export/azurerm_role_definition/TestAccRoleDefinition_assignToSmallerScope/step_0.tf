
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031355093268"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "ee099f96-c02d-4abc-bd3c-a6a68718f373"
  name               = "acctestrd-240311031355093268"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
