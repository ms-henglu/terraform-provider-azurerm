
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ASSC-220324175928934114"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-220324175928934114"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-220324175928934114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}


resource "azurerm_app_service_source_control" "test" {
  app_id        = azurerm_linux_web_app.test.id
  use_local_git = true
}
