
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122240617431"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-240315122240617431"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_static_web_app" "test" {
  name                = "acctestSS-240315122240617431"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"

  configuration_file_changes_enabled = false
  preview_environments_enabled       = false

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  app_settings = {
    "foo" = "bar"
  }

  basic_auth {
    password     = "Super$3cretPassW0rd"
    environments = "AllEnvironments"
  }

  tags = {
    environment = "acceptance"
  }
}
