
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324155928087099"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d9632ae2-eadb-4270-aab0-bfd0f9d7facb"
  name               = "acctestrd-220324155928087099"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
