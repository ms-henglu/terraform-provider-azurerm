

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-240119024619124854"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-240119024619124854"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "accTestOriginGroup-240119024619124854"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "accTestOrigin-240119024619124854"
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

resource "azurerm_cdn_frontdoor_endpoint" "test" {
  name                     = "accTestEndpoint-240119024619124854"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}

resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "accTestRuleSet240119024619124854"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_route" "test" {
  name                          = "accTestRoute-240119024619124854"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.test.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.test.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.test.id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.test.id]
  cdn_frontdoor_origin_path     = "/example"

  enabled                = true
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cache {
    query_strings                 = ["foo", "bar"]
    query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
  }
}
