

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-vscgtl-230922062114755619"
  location = "West Europe"
}

resource "azurerm_voice_services_communications_gateway" "test" {
  name                = "acctest-vscg-k1tuo"
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


resource "azurerm_voice_services_communications_gateway_test_line" "test" {
  name                                     = "acctest-tl-k1tuo"
  location                                 = "West Europe"
  voice_services_communications_gateway_id = azurerm_voice_services_communications_gateway.test.id
  phone_number                             = "123456789"
  purpose                                  = "Automated"
}
