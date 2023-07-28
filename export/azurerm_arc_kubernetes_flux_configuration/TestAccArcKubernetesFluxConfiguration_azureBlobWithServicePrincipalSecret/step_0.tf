
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025105036466"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025105036466"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230728025105036466"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025105036466"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230728025105036466"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6573!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230728025105036466"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsH4OwmUvKNePGQ5wagcNB7BbfkzyzB1a7SOVWgaiCBXLbBTTRcH/v9abttCtwL38+WFNf7SprQebnyteaiqN3iDihNOa0L22NupDKrg21fHY+22zswMf9qONhoXBRSN4JkwvYKP+BW/xel+E9r3Ks4NiLaggaSWYIY0kHBZGADqUM5+0LR+651ZDX5L7MeU8jCir4nE4qtaYqdzquvxPExEDd3p9uSJtDEs94qHzk2isMY8z4pGgkRyYF5ddFXPAWrIokybEhRRE4temejF+nM+uslobJ4n0c601YgYWOfAHcgMEiDckeLRFseKfFUAEUvmwzrFbdeyt4O6vaKnekPGalLR3JheRodbvNV8V22cqqkQRZsDNd3wgowsizzIoK9xqiDfi3yncWdRCl0urZ8rDKOT5BGkHWiZlxJdolOlQ9qWZTULBz6Bb2NJvWY3lyFRiZ9lzhJMX8K5BVdpPlA8hJ40EECVzc7hIZ8X+a5h+8yJ7ARpmQai5YoivIf/WZtlMMotNUdneLYckbmHmXtSSiz9oJ1mNpb8lCYC5SyLWrXoZJNsDNQ86six1P+pOGGFHCEPGjyL4n625PnO3elfRpo82RF/EDhSonoRVsOO5ovPvE7FITqiH04R3IkzgRq4smWG8gAYm/rg4fQpjygnoSxZ5cdS0RvmMWbsSjWkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6573!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025105036466"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEAsH4OwmUvKNePGQ5wagcNB7BbfkzyzB1a7SOVWgaiCBXLbBTT
RcH/v9abttCtwL38+WFNf7SprQebnyteaiqN3iDihNOa0L22NupDKrg21fHY+22z
swMf9qONhoXBRSN4JkwvYKP+BW/xel+E9r3Ks4NiLaggaSWYIY0kHBZGADqUM5+0
LR+651ZDX5L7MeU8jCir4nE4qtaYqdzquvxPExEDd3p9uSJtDEs94qHzk2isMY8z
4pGgkRyYF5ddFXPAWrIokybEhRRE4temejF+nM+uslobJ4n0c601YgYWOfAHcgME
iDckeLRFseKfFUAEUvmwzrFbdeyt4O6vaKnekPGalLR3JheRodbvNV8V22cqqkQR
ZsDNd3wgowsizzIoK9xqiDfi3yncWdRCl0urZ8rDKOT5BGkHWiZlxJdolOlQ9qWZ
TULBz6Bb2NJvWY3lyFRiZ9lzhJMX8K5BVdpPlA8hJ40EECVzc7hIZ8X+a5h+8yJ7
ARpmQai5YoivIf/WZtlMMotNUdneLYckbmHmXtSSiz9oJ1mNpb8lCYC5SyLWrXoZ
JNsDNQ86six1P+pOGGFHCEPGjyL4n625PnO3elfRpo82RF/EDhSonoRVsOO5ovPv
E7FITqiH04R3IkzgRq4smWG8gAYm/rg4fQpjygnoSxZ5cdS0RvmMWbsSjWkCAwEA
AQKCAgA3MjVLdnmZPFD0dR+TCUF59h2nEkmcrFGTeF1tGkXyYV6NHrY0SsfBJ0zr
j7fHX6OOGnAyUD4AbzCsRtPwP/6+SWqOP99bCPnDkuAOrC36GvjRKS3Z/lAwwlWw
jIQ1KzKYR5tJjgATkz7iFp1uzUxnd99sh/ga6jb5xzpTzmN2DtvqiTfAJPw+/St0
6HLG1/pnmxCmcOJYC2UTOpPuhpn0TI3Y/+Xx0GJqRd3E0wFqSIIRvcdsRD8DIv4t
4pip7Nlrg+xMmQM822nvx6G49WGziQAJp0R2yR46TyEy1tR8qiSp82enchdl6Hsj
dsxpyOuRR6WT/sOrzalTf1I8WWPRS7t293qIcfmYRngh5Y2uWanHxt3Lgu8uZMpF
jYwGDOF8Ah+LMYn50fFyyuwLSfQMGw7vanq6C7VXMXNg4/YxdHwKvXsqg/9dc2wo
9mEmkZAYM0nC8OPqMRj0k4TzA4T2To2IEU4L4U8yTcsaWRiVeJ9DDdvJ/KFUt13N
wyQIyzA0xblZwH6ie2bYhVCW6hGUhMPikYnnrP9emgmLuIJL/l2lDqj8OIBSnBOK
dDggTgdSsAb5c1PwjbH7ZRGfkgHTt717t9ETXBsp9k0RofLsuSndU5EkaJXT4rUT
cy4IlR6JI1SNx4MqAMm7FbOdMED5NLzxlXLKyoXOC16qrDGAAQKCAQEAznmQLCgc
zoLPhGfKuZQRLE5zDfWgLSLQqSugI1HrNLCgjBYeqcdin0cnShQXg1DFXogwdpVw
3lpWvL20EFE+gDeFhclHrlpiIeWWpi+7t8pM5gb5g+OP6Ci/kRA+vhSUkKkS3xfU
uoODSbfgcsUNxfcZgvNSuMBJzDJjom/jO4GN4oaC7KOfNusHaYwQrPgH3xeQkfA1
8ubq+duzYEQJWffhYAnLVI9Z+YtEQFvTi8kEba4/ZHuBm48BtdhXIUXAimsYlOGh
KwrrKGQQf1XTQSSe/RJbIeHzFIJRo4jHjiPtwolk8UoXieeEuAhSI9J+G770SGgV
ctmNw5SohqgsaQKCAQEA2tNxz282SzsPEvk5HTf/skPqqb+eMwIqq+EY/ZRK/5I2
Vcf0ogb15cVM9ulGjWiMQFOeyJd6rkF2CcybU9e4M19lnT2i3gXixHyy2mLTwqOn
Wr95l6ABMf1PVaDr1pXN44rIjavq44EuOKOcp+vYT8YON9NS8pf2Wpjq5zlM9y3g
4jY0ZJp49MTvmy7lRIM9swb6aPdUCaLJpDXhMUUJ0fFXChjOalFYCDgKgMA8h5en
i1uDmPsRGxDF2Vb0ERPtcUHwonB535uu/sP0wGVnLTEDMm9OhXrJL5aEX50SKZA0
IDmsZQtFEEke4QddA1433+VQLiNYBOtnQplKWW85AQKCAQEAiFkCegZrL3x2qUsZ
Nn+u74FGvTss8WGCRZTHhUt9dSgGfTvGN/uxBtmn+mVWOaNHEuwAhO6ewFcL3Eux
8uyTx3visrx+l4acMyI337q5zd7L9UM51nyZ9YejKZp+tGtGyFi+W5CTLC/YrP++
Okwikk5hDHa+c76XfT7xSL12Yz9kgOiu4LIUW+HM3UhfYrnQCOS41Ya5OZSAK0uI
ItQLENx+ejs9iLO5iO8MvStmgXLXd86Pkj11E1LWoE0jDJfRVBbw/rAZDCGDtQKP
WmdEwEn8q8ZJZBCfwzVj0AhtL1JOmh69CBIThT/cBuOHypwgJxZsnrwNHfDIixVK
TNIVsQKCAQA7ddknFIEcUB/4d+AdIGpKdkn9diP2mFAgBDpWLUVzzLcW+A5xOJL4
rHQNY7XYFuCFWjN7Li4Xy5HXd9F9JtDWpMVnxKfMzKyh14CB9vizmuSOtBjGKqQo
gTxdeCydUndvrPZyCJT63M9CdLLMrjlI8/hJExMm+EPoukSaL+fKAp1o2nHCJHdZ
i2nQMR37T+4kB3FjtFERjTpddIaMbMYOVhXgmHz+Rrw0/4VbFuFbtsnABE3t88ri
H9yjAg2v1kpezBwnB4kWSadzcqu+2879aKQFwFkFzCd+1teBY5zbzmNbnlBJ5JYP
ps7NNsL/d0qXfCgdYV05eP3GCwE47BABAoIBADWh91ohoz43Na/2GAAgXuc3rEzX
Z03EzuWsrCUkHmw+KWPuyA7stV9I0MN5OE2HY+5kZA/3ErqHyUZcOVYjWOCZWhXP
/veOHYn1/4XKVJDPOh4nGYDdT0RkbFycUdrxVmhYplCu0wwtbCzJcqhIqwQ3Wo1u
2PX4iwcQ3Q9frf5C8maVYJ5UqqSlHSbjoNtp0MnPkmY09ccKvUM0iOTYrvY0/nJK
8TMas9ciVIqYeXQEWcsFG3TphHua9YfIlSdbDdyOiXNOZNqOFhSmsJcC1nKo2WSg
NP6rzrduQnmjmCIauwYp+cYWS4odHKFqYTPmUds6ACCn0d9MZNYldsiv6eM=
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230728025105036466"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230728025105036466"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728025105036466"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230728025105036466"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
