
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctest-230728032844540189"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "DefaultTags"

  policy_rule = <<POLICY_RULE
    {
  "if": {
    "field": "tags",
    "exists": "false"
  },
  "then": {
    "effect": "append",
    "details": [
      {
        "field": "tags",
        "value": {
          "environment": "D-137",
          "owner": "Rick",
          "application": "Portal",
          "implementor": "Morty"
        }
      }
    ]
  }
  }
POLICY_RULE
}
