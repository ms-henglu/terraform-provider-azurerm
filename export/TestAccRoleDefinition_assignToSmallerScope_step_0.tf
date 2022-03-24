
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324162946606274"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "fa3f30dd-acf7-42e3-91cc-385c49cbdc8a"
  name               = "acctestrd-220324162946606274"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
