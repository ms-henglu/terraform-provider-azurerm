
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "AcctestRG-230825024235250944"
  location = "West Europe"
}

resource "azurerm_ssh_public_key" "test" {
  name                = "tf.test-public-key-230825024235250944"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0/NDMj2wG6bSa6jbn6E3LYlUsYiWMp1CQ2sGAijPALW6OrSu30lz7nKpoh8Qdw7/A4nAJgweI5Oiiw5/BOaGENM70Go+VM8LQMSxJ4S7/8MIJEZQp5HcJZ7XDTcEwruknrd8mllEfGyFzPvJOx6QAQocFhXBW6+AlhM3gn/dvV5vdrO8ihjET2GoDUqXPYC57ZuY+/Fz6W3KV8V97BvNUhpY5yQrP5VpnyvvXNFQtzDfClTvZFPuoHQi3/KYPi6O0FSD74vo8JOBZZY09boInPejkm9fvHQqfh0bnN7B6XJoUwC1Qprrx+XIy7ust5AEn5XL7d4lOvcR14MxDDKEp you@me.com"
  tags = {
    test-tag : "test-value-230825024235250944"
  }

}
