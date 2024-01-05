
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ya8q14xwu40ml9ncljownidhik4vu3bhbcrrwqasr"
  token_secret = "9jvetl1qzgpmxxvsq9kng4ipwpvi1zdzp0t4aqwwq"
}
