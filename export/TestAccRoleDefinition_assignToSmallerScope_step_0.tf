
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211130213600589"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2315c17d-3836-4558-ac3a-7e92c145a5b0"
  name               = "acctestrd-220211130213600589"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
