
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022552692416"
  location = "West Europe"
}

resource "azurerm_web_application_firewall_policy" "test" {
  name                = "acctestwafpolicy-240119022552692416"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_settings {
    enabled = true
    mode    = "Detection"
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "x-shared-secret"
      selector_match_operator = "Equals"

      excluded_rule_set {
        type    = "Microsoft_DefaultRuleSet"
        version = "2.1"
        rule_group {
          rule_group_name = "PROTOCOL-ENFORCEMENT"
          excluded_rules = [
            "920100",
            "920120",
          ]
        }
      }
    }

    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"

      rule_group_override {
        rule_group_name = "METHOD-ENFORCEMENT"
        rule {
          id      = "911100"
          enabled = true
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "LFI"
        rule {
          id      = "930100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "RFI"
        rule {
          id      = "931100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "RCE"
        rule {
          id      = "932100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "PHP"
        rule {
          id      = "933100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "NODEJS"
        rule {
          id      = "934100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "XSS"
        rule {
          id      = "941100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "SQLI"
        rule {
          id      = "942100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "FIX"
        rule {
          id      = "943100"
          enabled = false
          action  = "Log"
        }
      }

      rule_group_override {
        rule_group_name = "JAVA"
        rule {
          id      = "944100"
          enabled = false
          action  = "Log"
        }
      }
    }
  }
}
