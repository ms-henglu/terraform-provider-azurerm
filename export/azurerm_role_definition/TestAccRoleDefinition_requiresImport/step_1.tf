

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2c77a992-0f63-4137-9246-a88f0162a2ee"
  name               = "acctestrd-221111020015214050"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}


resource "azurerm_role_definition" "import" {
  role_definition_id = azurerm_role_definition.test.role_definition_id
  name               = azurerm_role_definition.test.name
  scope              = azurerm_role_definition.test.scope

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}
