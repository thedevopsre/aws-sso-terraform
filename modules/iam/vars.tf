variable "identity_store_id" {
  type = string
  description = "Instance store id in which access management should be organized"
}

variable "Users" {
  description = "List of users, in object format"

  type = list(object({
    username = string
    group = string
    group_desc = optional(string)
    create_group = bool
    email = string
    name = string
    second_name = string
  }))
}

variable "Permissions" {
  description = "List of permissions and account bindings"
  type = list(object({
    type = string # USER or GROUP
    name = string
    policy_path = string
    account_id = string
  }))
}
