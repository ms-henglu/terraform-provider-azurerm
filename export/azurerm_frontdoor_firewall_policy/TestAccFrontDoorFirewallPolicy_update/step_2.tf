
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025100200231"
  location = "West Europe"
}

resource "azurerm_frontdoor_firewall_policy" "test" {
  name                              = "testAccFrontDoorWAF240119025100200231"
  resource_group_name               = azurerm_resource_group.test.name
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://www.contoso.com"
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
  }

  tags = {
    ENV = "Test"
  }
}
