
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-240112033813672432"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240112033813672432"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-240112033813672432"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_app_service_plan.test.id

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}

resource "azurerm_linux_web_app_slot" "test" {
  name           = "acctestWAS-240112033813672432"
  app_service_id = azurerm_linux_web_app.test.id

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}


resource "azurerm_app_service_source_control_slot" "test" {
  slot_id       = azurerm_linux_web_app_slot.test.id
  use_local_git = true
}
