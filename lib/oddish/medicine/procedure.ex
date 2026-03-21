defmodule Oddish.Medicine.Procedure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "procedures" do
    field :name, :string
    field :type, Ecto.Enum, values: [:consultation, :vaccine, :insemination, :touch]
    field :org_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(procedure, attrs, organization_scope) do
    procedure
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
    |> put_change(:org_id, organization_scope.organization.id)
  end
end
