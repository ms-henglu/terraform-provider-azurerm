
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408050918075086"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4ab8e001-2351-4ad5-af56-f4d6877e8fd3"
  name               = "acctestrd-220408050918075086"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
