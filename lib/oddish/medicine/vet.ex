defmodule Oddish.Medicine.Vet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vets" do
    field :name, :string
    field :telephone, :string
    field :email, :string
    field :org_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vet, attrs, organization_scope) do
    vet
    |> cast(attrs, [:name, :telephone, :email])
    |> validate_required([:name, :telephone, :email])
    |> put_change(:org_id, organization_scope.organization.id)
  end
end
