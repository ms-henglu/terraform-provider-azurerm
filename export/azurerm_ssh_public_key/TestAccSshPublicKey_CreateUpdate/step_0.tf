
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "AcctestRG-231013043133459137"
  location = "West Europe"
}

resource "azurerm_ssh_public_key" "test" {
  name                = "tf.test-public-key-231013043133459137"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
  tags = {
    test-tag : "test-value-231013043133459137"
  }

}
