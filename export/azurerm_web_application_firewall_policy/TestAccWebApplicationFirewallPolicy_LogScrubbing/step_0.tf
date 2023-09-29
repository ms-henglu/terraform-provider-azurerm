
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065415046630"
  location = "West Europe"
}

resource "azurerm_web_application_firewall_policy" "test" {
  name                = "acctestwafpolicy-230929065415046630"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_settings {
    enabled = true
    mode    = "Detection"
    log_scrubbing {
      enabled = true
      rule {
        enabled                 = true
        match_variable          = "RequestHeaderNames"
        selector_match_operator = "Equals"
        selector                = "User-Agent"
      }
    }
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"

      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}
