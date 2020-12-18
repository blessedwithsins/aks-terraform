# Azure Resource Group for AKS Cluster ## 
resource "azurerm_resource_group" "terraform" {
    name     = var.resource_group_name
    location = var.location
}

# egress IP
resource "azurerm_public_ip" "aks_egress_ip" {
  name                = var.aks_eip_name
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.aks_eip_name
}

# AKS Cluster ## 
resource "azurerm_kubernetes_cluster" "aks-terraform" {
   name                = var.cluster_name
   resource_group_name = azurerm_resource_group.terraform.name
   location            = azurerm_resource_group.terraform.location
   dns_prefix          = var.dns_prefix
   kubernetes_version =  var.kubernetes_version

   linux_profile {
     admin_username = var.admin_username

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = var.default_nodepool_name
        node_count      = var.agent_count
        vm_size         = var.vm_size
        max_pods        = var.max_pods
        os_disk_size_gb = var.os_disk_size_gb
        availability_zones = var.availability_zones
        node_taints        = var.node_taints
        node_labels        = var.node_labels
        enable_auto_scaling = var.enable_auto_scaling
        min_count          = var.min_count
        max_count          = var.max_count
    }

    auto_scaler_profile {
      balance_similar_node_groups      = var.balance_similar_node_groups
      max_graceful_termination_sec     = var.max_graceful_termination_sec
      scale_down_delay_after_add       = var.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.scale_down_delay_after_failure
      scan_interval                    = var.scan_interval
      scale_down_unneeded              = var.scale_down_unneeded
      scale_down_unready               = var.scale_down_unready
      scale_down_utilization_threshold = var.scale_down_utilization_threshold
    }
  
    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = false
        }
    }

    network_profile {
        network_plugin     = "azure"
        network_policy     = "azure"
        service_cidr       = "10.255.0.0/16"
        dns_service_ip     = "10.255.0.10"
        docker_bridge_cidr = "172.17.0.1/16"
        load_balancer_sku  = "standard"  
        load_balancer_profile {
            outbound_ip_address_ids = [ azurerm_public_ip.aks_egress_ip.id ]
            idle_timeout_in_minutes = 60
            }
    }

    tags = var.tags 
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}



