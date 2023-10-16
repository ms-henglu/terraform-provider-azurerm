
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-231016033515759569"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-231016033515759569"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "accTestOriginGroup-231016033515759569"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "accTestOrigin-231016033515759569"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.test.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = "contoso.com"
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = "www.contoso.com"
  priority                       = 1
  weight                         = 1
}

resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "accTestRuleSet231016033515759569"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_rule" "test" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.test, azurerm_cdn_frontdoor_origin.test]

  name                      = "accTestRule231016033515759569"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.test.id

  order = 0

  conditions {
    request_uri_condition {
      match_values     = ["https://contoso.com/test"]
      negate_condition = false
      operator         = "Equal"
    }
  }

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      query_string         = "TE=&PFalse=&source=TE&medium=mai&campaign=y10"
      destination_hostname = "contoso.com"
      destination_path     = "/test/page"
    }
  }
}
