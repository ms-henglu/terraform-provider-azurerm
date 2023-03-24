
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324051631194278"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "f99f89cb-002c-4b01-a62e-ae5528b27366"
  name               = "acctestrd-230324051631194278"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
