
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025429827565"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "fc7a5e52-c1b3-438d-b601-2f52448a4acf"
  name               = "acctestrd-230804025429827565"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
