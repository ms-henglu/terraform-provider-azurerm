
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "9weqhockhl0kspo4n9z8fedv19rr2zhq97bryhg6a"
  token_secret = "ndokzd1ixmjxx0ym789h6ntzp6txcucsfi1srb1r9"
}
