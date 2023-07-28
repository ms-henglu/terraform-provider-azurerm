
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230728031903681759"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-230728031903681759"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "accTestOriginGroup-230728031903681759"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "accTestOrigin-230728031903681759"
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
  name                     = "accTestRuleSet230728031903681759"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_rule" "test" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.test, azurerm_cdn_frontdoor_origin.test]

  name                      = "accTestRule230728031903681759"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.test.id

  order = 0

  conditions {
    url_path_condition {
      operator         = "RegEx"
      negate_condition = false
      match_values     = ["api/?(.*)"]
      transforms       = ["Lowercase", "Trim"]
    }
  }

  actions {
    route_configuration_override_action {
      cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.test.id
      forwarding_protocol           = "HttpsOnly"
      cache_behavior                = "Disabled"
    }
  }
}
