resource "azurerm_network_interface" "nic" {
  for_each             = var.vms
  name                 = "nic-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name

  ip_configuration {
    name                          = "${each.value.name}-internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each             = var.vms
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  size                 = each.value.vm_size
  admin_username       = each.value.acc.admin_username
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  admin_ssh_key {
    username   = each.value.acc.admin_username
    public_key = each.value.acc.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = try(base64encode(file(each.value.custom_data_path)), null)

  tags = merge(
    var.tags,
    {
      workload = "vm"
    }
)
}