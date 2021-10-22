
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "kyb1ucpjxww37v09ketwyut2s1origm6js27xnyz2"
  token_secret = "fdbcilj8azmxx0a8s3cz8m6sax12xzhm2knliwui4"
}
