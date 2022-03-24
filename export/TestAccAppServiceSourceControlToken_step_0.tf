
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "jp8kg1epgpc6re6zh7srs9sphuscjdjcvjb3gj10y"
  token_secret = "alxjegmswlslyzpvbvehqwfidzag3wou6c32bcrpk"
}
