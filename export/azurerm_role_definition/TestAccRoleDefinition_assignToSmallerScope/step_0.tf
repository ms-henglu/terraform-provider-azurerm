
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030139962560"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "747ce0eb-95fe-4ff5-9381-0017d713272d"
  name               = "acctestrd-230602030139962560"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
