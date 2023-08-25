
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025504261717"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230825025504261717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-230825025504261717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    ip_restriction {
      ip_address = "10.10.10.10/32"
      name       = "test-restriction"
      priority   = 123
      action     = "Allow"
    }

    ip_restriction {
      ip_address = "20.20.20.0/24"
      name       = "test-restriction-2"
      priority   = 1234
      action     = "Deny"
    }

    ip_restriction {
      ip_address = "2400:cb00::/32"
      name       = "test-restriction-3"
      action     = "Deny"
    }

    ip_restriction {
      service_tag = "AzureEventGrid"
      name        = "test-restriction-4"
      action      = "Allow"
    }
  }
}
