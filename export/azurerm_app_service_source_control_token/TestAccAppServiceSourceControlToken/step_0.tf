
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "aqacyp38u8hfnd3oub6cv0kmqb46e6yoyzyxbubbi"
  token_secret = "xouwcfi4s1d471l7ashwiztduc0ft6dvmlquxikxy"
}
