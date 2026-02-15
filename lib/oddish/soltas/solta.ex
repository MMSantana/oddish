defmodule Oddish.Soltas.Solta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "soltas" do
    field :name, :string
    field :area, :decimal
    field :grass_type, :string
    field :org_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(solta, attrs, organization_scope) do
    solta
    |> cast(attrs, [:name, :area, :grass_type])
    |> validate_required([:name])
    |> unique_constraint([:org_id, :name], message: "Esse nome já está em uso")
    |> put_change(:org_id, organization_scope.organization.id)
  end
end
