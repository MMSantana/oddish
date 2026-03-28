# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Oddish.Repo.insert!(%Oddish.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# {:ok, me} = Oddish.Accounts.register_user(%{email: "email@gmail.com"})
# scope = Oddish.Accounts.Scope.for_user(me)

# {:ok, org} =
#   Oddish.Accounts.Organization.create_organization(
#     %{
#       name: "Madalena",
#       slug: "madalena",
#       tier: "S"
#     },
#     scope
#   )

# # scope = Oddish.Accounts.Scope.put_organization(scope, org)

# login_string = Oddish.Accounts.local_login_instructions(me)

# IO.puts(login_string)
