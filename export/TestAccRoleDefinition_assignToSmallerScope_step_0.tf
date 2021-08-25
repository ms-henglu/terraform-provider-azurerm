
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044513741916"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2569ef60-ad54-4f0e-a883-d511d8156ed6"
  name               = "acctestrd-210825044513741916"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
