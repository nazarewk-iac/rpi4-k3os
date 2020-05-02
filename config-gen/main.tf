locals {
  configs-path = format("%s/cloud-configs", path.module)
}

data "template_cloudinit_config" "cloud-configs" {
  for_each = var.nodes

  base64_encode = false
  gzip          = false

  dynamic "part" {
    for_each = [
      "base",
      each.key,
    ]

    content {
      content = file(format("%s/%s.yaml", local.configs-path, each.value.role))
    }
  }

  part {
    content = format("k3os: server_url: https://%s:6443", )
  }
}

resource "local_file" "cloud-inits" {
  for_each = var.nodes

  filename = format("%s/../tf-config/%s.yaml", path.module, each.key)

  content         = data.template_cloudinit_config.cloud-configs[each.key].rendered
  file_permission = "0640"
}
