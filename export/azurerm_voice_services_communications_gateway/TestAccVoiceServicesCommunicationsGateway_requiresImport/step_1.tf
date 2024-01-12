


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112035342158371"
  location = "West Europe"
}


resource "azurerm_voice_services_communications_gateway" "test" {
  name                = "acctest-vscg-gckfl"
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


resource "azurerm_voice_services_communications_gateway" "import" {
  name                = azurerm_voice_services_communications_gateway.test.name
  resource_group_name = azurerm_voice_services_communications_gateway.test.resource_group_name
  location            = azurerm_voice_services_communications_gateway.test.location
  connectivity        = azurerm_voice_services_communications_gateway.test.connectivity
  e911_type           = azurerm_voice_services_communications_gateway.test.e911_type
  codecs              = azurerm_voice_services_communications_gateway.test.codecs
  platforms           = azurerm_voice_services_communications_gateway.test.platforms
  on_prem_mcp_enabled = azurerm_voice_services_communications_gateway.test.on_prem_mcp_enabled

  service_location {
    location                                  = "eastus"
    allowed_media_source_address_prefixes     = ["10.1.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.1.1.0/24"]
    operator_addresses                        = ["198.51.100.1"]
  }

  service_location {
    location                                  = "eastus2"
    allowed_media_source_address_prefixes     = ["10.2.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.2.1.0/24"]
    operator_addresses                        = ["198.51.100.2"]
  }
}
