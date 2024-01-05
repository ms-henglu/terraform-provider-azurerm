



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240105064811865898"
  location = "West Europe"
}


resource "azurerm_voice_services_communications_gateway" "test" {
  name                = "acctest-vscg-on3bc"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  connectivity        = "PublicAddress"
  e911_type           = "Standard"
  codecs              = "PCMU"
  platforms           = ["OperatorConnect"]

  service_location {
    location                                  = "eastus2"
    allowed_media_source_address_prefixes     = ["10.1.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.1.1.0/24"]
    operator_addresses                        = ["198.51.100.1"]
  }

  service_location {
    location                                  = "eastus"
    allowed_media_source_address_prefixes     = ["10.2.2.0/24"]
    allowed_signaling_source_address_prefixes = ["10.2.1.0/24"]
    operator_addresses                        = ["198.51.100.2"]
  }

  auto_generated_domain_name_label_scope = "SubscriptionReuse"
  emergency_dial_strings                 = ["911"]
  microsoft_teams_voicemail_pilot_number = "2"

  tags = {
    Environment = "dev"
  }
}
