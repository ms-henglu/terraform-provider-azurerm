
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021234709321310"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "902e9c98-afab-43ef-986f-f79da3cf71a0"
  name               = "acctestrd-211021234709321310"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
