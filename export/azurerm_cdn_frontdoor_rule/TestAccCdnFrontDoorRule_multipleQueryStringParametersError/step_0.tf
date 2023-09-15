
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230915023019331117"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-230915023019331117"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "accTestOriginGroup-230915023019331117"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "accTestOrigin-230915023019331117"
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
  name                     = "accTestRuleSet230915023019331117"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_rule" "test" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.test, azurerm_cdn_frontdoor_origin.test]

  name                      = "accTestRule230915023019331117"
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
      query_string         = "origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.com&destination_host=fabrikam.com&redirect_from=frontdoor&origin_host=contoso.c"
      destination_hostname = "fabrikam.com"
      destination_path     = "/test/page"
    }
  }
}
