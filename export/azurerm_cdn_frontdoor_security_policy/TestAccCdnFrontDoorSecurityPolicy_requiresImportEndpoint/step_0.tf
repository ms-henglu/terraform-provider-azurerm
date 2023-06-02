
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230602030226237217"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_firewall_policy" "test" {
  name                              = "accTestWAF230602030226237217"
  resource_group_name               = azurerm_resource_group.test.name
  sku_name                          = azurerm_cdn_frontdoor_profile.test.sku_name
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://www.fabrikam.com"
  custom_block_response_status_code = 403
  custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

  custom_rule {
    name                           = "Rule1"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "preview-0.1"
    action  = "Block"

    override {
      rule_group_name = "PHP"

      rule {
        rule_id = "933111"
        enabled = false
        action  = "Block"
      }
    }
  }

  managed_rule {
    type    = "BotProtection"
    version = "preview-0.1"
    action  = "Block"
  }
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230602030226237217.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-230602030226237217"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Premium_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "test" {
  name                     = "acctest-cdnfdendpoint-230602030226237217"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_security_policy" "test" {
  name                     = "accTestSecPol230602030226237217"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.test.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.test.id
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
