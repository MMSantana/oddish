defmodule Oddish.Accounts.UserOrganization do
  use Ecto.Schema

  import Ecto.Changeset

  alias Oddish.Repo
  alias Oddish.Accounts.UserOrganization

  @primary_key false
  schema "user_organizations" do
    belongs_to :user, Oddish.Accounts.User, primary_key: true
    belongs_to :organization, Oddish.Accounts.Organization, primary_key: true
    field :role, Ecto.Enum, values: [:admin, :manager, :member], primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_organization, attrs) do
    user_organization
    |> cast(attrs, [:user_id, :organization_id, :role])
    |> validate_required([:user_id, :organization_id, :role])
    |> validate_inclusion(:role, [:admin, :manager, :member])
    |> unique_constraint([:user_id, :organization_id, :role])
  end

  def filliate_user(%Oddish.Accounts.User{id: user_id}, %Oddish.Accounts.Organization{
        id: organization_id
      }) do
    changeset(%UserOrganization{}, %{
      user_id: user_id,
      organization_id: organization_id,
      role: :member
    })
    |> Repo.insert()
  end
end
