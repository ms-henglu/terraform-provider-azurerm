
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031849444500"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "accteste4u8c"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_redis_cache" "test" {
  name                = "acctestRedis-230106031849444500"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  redis_configuration {
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  tags = {
    environment = "production"
  }
}
