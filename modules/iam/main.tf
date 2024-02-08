resource "aws_identitystore_user" "identity_user" {

  for_each = { for i, user in var.Users: user.username => user }

  identity_store_id = var.identity_store_id
  display_name      = format("%s %s",each.value.name, each.value.second_name)
  user_name         = each.value.username

  name {
    given_name  = each.value.name
    family_name = each.value.second_name
  }

  emails {
    primary = true
    value   = each.value.email
  }
}

resource "aws_identitystore_group" "identity_store_group" {
  for_each = { for i, user in var.Users: user.username => user if user.create_group }

  identity_store_id = var.identity_store_id
  display_name      = each.value.group
  description       = each.value.group_desc
}

resource "aws_identitystore_group_membership" "identity_store_group" {
  for_each = { for i, user in var.Users: user.username => user }
  identity_store_id = var.identity_store_id
  group_id          = each.value.create_group ? aws_identitystore_group.identity_store_group[each.key].group_id : data.aws_identitystore_group.group[each.key].id
  member_id         = aws_identitystore_user.identity_user[each.key].user_id
}

resource "aws_ssoadmin_permission_set_inline_policy" "permission_set" {
  for_each = { for i, permission in var.Permissions: "${permission.name}_${permission.account_id}"  => permission }

  inline_policy      = file(each.value.policy_path)
  instance_arn       = data.aws_ssoadmin_instances.permission_set.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.key].arn
}

resource "aws_ssoadmin_account_assignment" "account_assignment" {

  for_each = { for i, permission in var.Permissions: "${permission.name}_${permission.account_id}"  => permission }

  instance_arn       = data.aws_ssoadmin_instances.permission_set.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.key].arn

  principal_id   = each.value.type == "GROUP" ? data.aws_identitystore_group.group_assign[each.key].id : data.aws_identitystore_user.user_assign[each.key].id
  principal_type = each.value.type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

}
