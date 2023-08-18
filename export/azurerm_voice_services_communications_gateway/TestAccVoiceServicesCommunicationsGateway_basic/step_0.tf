

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230818024947204872"
  location = "West Europe"
}


resource "azurerm_voice_services_communications_gateway" "test" {
  name                = "acctest-vscg-3h72q"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  connectivity        = "PublicAddress"
  e911_type           = "Standard"
  codecs              = "PCMA"
  platforms           = ["OperatorConnect"]
  on_prem_mcp_enabled = false

  service_location {
    location           = "eastus"
    operator_addresses = ["198.51.100.1"]
  }

  service_location {
    location           = "eastus2"
    operator_addresses = ["198.51.100.2"]
  }
}
