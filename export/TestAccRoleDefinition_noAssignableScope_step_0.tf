
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9def6e6a-77a5-4680-8f46-6f88a63e9935"
  name               = "acctestrd-220826002345028024"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }
}
