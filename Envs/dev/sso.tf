module "identity_centre_access_management" {
  source = "../../modules/iam"

  identity_store_id = "AWS-IAM-IDENTITY-STORE-ID"

  Users = [
    {
      username = "FirstNameSurname"
      group_desc = "Team of Software developers"
      create_group = false
      group = "Software"
      email = "firstname.surname@domain.com"
      name = "FirstName"
      second_name = "Surname"
      display_name = "FirstName Surname"
    }
  ]

  Permissions = [{
    policy_path = "resources/policies/software-team.json"
    type = "GROUP"
    name = "Software"
    account_id = "AWS-ACCOUNT-ID"
  }]
}