
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2pugqy3s9el9sad6404nak73eqks3dqhxem4dnyn4"
  token_secret = "62jwzrcnsw7vlmepd1iz8jthoch3w412hksktgg8s"
}
