
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034931007824"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  name                = "acctestRG-231016034931007824"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestRG-231016034931007824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    always_on = true
  }
}

resource "azurerm_app_service_slot" "test" {
  name                = "acctestASSlot-231016034931007824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
  app_service_name    = azurerm_app_service.test.name

  auth_settings {
    enabled = true
    issuer  = "https://sts.windows.net/ARM_TENANT_ID"

    additional_login_params = {
      test_key = "test_value"
    }

    active_directory {
      client_id     = "aadclientid"
      client_secret = "aadsecret"

      allowed_audiences = [
        "activedirectorytokenaudiences",
      ]
    }
  }
}
