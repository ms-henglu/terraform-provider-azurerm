
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021540830007"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a338b21d-ceb7-48ed-9933-80607d1fe0df"
  name               = "acctestrd-240119021540830007"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
