data "aws_identitystore_group" "group_assign" {
  for_each = { for i, permission in var.Permissions: "${permission.name}_${permission.account_id}"  => permission }
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.name
    }
  }
}

data "aws_identitystore_user" "user_assign" {
  for_each = { for i, permission in var.Permissions: "${permission.name}_${permission.account_id}"  => permission if permission.type == "USER" }
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.name
    }
  }
}

data "aws_ssoadmin_instances" "permission_set" {}

resource "aws_ssoadmin_permission_set" "permission_set" {

  for_each = { for i, permission in var.Permissions: "${permission.name}_${permission.account_id}"  => permission }

  name         = "${each.key}"
  instance_arn = data.aws_ssoadmin_instances.permission_set.arns[0]
}

data "aws_identitystore_group" "group" {
  for_each = { for i, user in var.Users: user.username => user if user.create_group != true }
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.group
    }
  }

}