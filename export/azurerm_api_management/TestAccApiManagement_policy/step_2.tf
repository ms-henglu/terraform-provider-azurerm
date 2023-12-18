
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071134501670"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231218071134501670"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  policy {
    xml_link = "https://gist.githubusercontent.com/tombuildsstuff/4f58581599d2c9f64b236f505a361a67/raw/0d29dcb0167af1e5afe4bd52a6d7f69ba1e05e1f/example.xml"
  }
}
