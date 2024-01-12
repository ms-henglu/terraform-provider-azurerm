
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223948228105"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "eac53954-462c-4900-a87b-84d0356a9ffb"
  name               = "acctestrd-240112223948228105"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
