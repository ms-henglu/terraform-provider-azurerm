
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "h18i9eqe9hna81lwtgde7eecnflnns8g40wntitet"
  token_secret = "wzmrd6ch80nwbah2oibiylv7z71cijjqlk19wi8xc"
}
