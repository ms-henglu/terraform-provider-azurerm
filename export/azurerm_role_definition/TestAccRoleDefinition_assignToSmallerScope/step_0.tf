
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034237944822"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "eec52df8-ea0f-48f6-ab59-377a55ef3b9e"
  name               = "acctestrd-221222034237944822"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
