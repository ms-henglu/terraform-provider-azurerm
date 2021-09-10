
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "e41uc48ug1sd3ho6rhxsjy74wm34i4lnjlguma3tx"
  token_secret = "aev7z9ewvt3ad34pd49ozs1kynsbb4222fg6xoeqc"
}
