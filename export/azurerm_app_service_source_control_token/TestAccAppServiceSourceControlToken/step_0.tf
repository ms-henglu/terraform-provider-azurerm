
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4nhoom2mrtupmkaxmvu2ijd3sts4xxzvtubkxxthm"
  token_secret = "6p2oljczc6haep2ot4ynq14szdk0jm7u9sqrtbgmb"
}
