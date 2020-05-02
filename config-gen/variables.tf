variable "nodes" {
  type = map(object({
    role: string
    ip_address: string
  }))

  validation {
    condition = toset([for node in values(var.nodes) : node.role]) == toset(["master", "worker"])

    error_message = "Variables var.nodes[*].role must be one of: master, worker."
  }

  validation {
    condition = toset([for mac in keys(var.nodes) : regex("^[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}", lower(mac))]) != toset([""])
    error_message = "Variables keys in var.nodes must be valid MAC addresses."
  }
}
