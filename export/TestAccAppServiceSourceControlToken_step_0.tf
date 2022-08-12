
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "q1uro6sr6nryxobvxcnnzd8sbf7zsio7or7ssxda9"
  token_secret = "9ulh2sac29jsszjy93oxg383nhyaal7rvi6v637ks"
}
