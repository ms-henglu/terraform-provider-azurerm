


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034920184892"
  location = "West Europe"
}


resource "azurerm_voice_services_communications_gateway" "test" {
  name                = "acctest-vscg-z0qha"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"

  connectivity = "PublicAddress"
  e911_type    = "DirectToEsrp"
  codecs       = "PCMA"
  platforms    = ["OperatorConnect", "TeamsPhoneMobile"]

  service_location {
    location                                  = "eastus"
    allowed_media_source_address_prefixes     = ["10.1.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.1.1.0/24"]
    esrp_addresses                            = ["198.51.100.3"]
    operator_addresses                        = ["198.51.100.1"]
  }

  service_location {
    location                                  = "eastus2"
    allowed_media_source_address_prefixes     = ["10.2.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.2.1.0/24"]
    esrp_addresses                            = ["198.51.100.4"]
    operator_addresses                        = ["198.51.100.2"]
  }

  api_bridge                             = jsonencode({})
  auto_generated_domain_name_label_scope = "SubscriptionReuse"
  on_prem_mcp_enabled                    = true
  microsoft_teams_voicemail_pilot_number = "1"
  emergency_dial_strings                 = ["911", "933"]

  tags = {
    Environment = "Test"
  }
}
