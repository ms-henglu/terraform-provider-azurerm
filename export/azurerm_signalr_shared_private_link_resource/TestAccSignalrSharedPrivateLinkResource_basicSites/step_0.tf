

provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-signalr-240119025830598549"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalr-240119025830598549"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119025830598549"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}
resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240119025830598549"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}

resource "azurerm_signalr_shared_private_link_resource" "test" {
  name               = "acctest-240119025830598549"
  signalr_service_id = azurerm_signalr_service.test.id
  sub_resource_name  = "sites"
  target_resource_id = azurerm_windows_web_app.test.id
  request_message    = "please approve"
}
