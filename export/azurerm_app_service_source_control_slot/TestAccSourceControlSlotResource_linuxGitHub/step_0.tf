
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-240311031305956791"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240311031305956791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-240311031305956791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}

resource "azurerm_linux_web_app_slot" "test" {
  name           = "acctestWAS-240311031305956791"
  app_service_id = azurerm_linux_web_app.test.id

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}


resource "azurerm_source_control_token" "test" {
  type  = "GitHub"
  token = "ARM_GITHUB_ACCESS_TOKEN"
}

resource "azurerm_app_service_source_control_slot" "test" {
  slot_id                = azurerm_linux_web_app_slot.test.id
  repo_url               = "https://github.com/Azure-Samples/python-docs-hello-world.git"
  branch                 = "master"
  use_manual_integration = true

  depends_on = [
    azurerm_source_control_token.test,
  ]
}
