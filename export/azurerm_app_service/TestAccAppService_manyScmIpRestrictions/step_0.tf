
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035346417609"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240112035346417609"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-240112035346417609"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    scm_ip_restriction {
      ip_address = "10.10.10.10/32"
    }

    scm_ip_restriction {
      ip_address = "20.20.20.0/24"
    }

    scm_ip_restriction {
      ip_address = "30.30.0.0/16"
    }

    scm_ip_restriction {
      ip_address = "192.168.1.2/24"
    }
  }
}
