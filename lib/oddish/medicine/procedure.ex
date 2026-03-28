defmodule Oddish.Medicine.Procedure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "procedures" do
    field :name, :string
    field :kind, Ecto.Enum, values: [:consultation, :vaccine, :iatf]
    field :org_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(procedure, attrs, organization_scope) do
    procedure
    |> cast(attrs, [:name, :kind])
    |> validate_required([:name, :kind], message: "Não pode estar em branco")
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def present_type(status) do
    case status do
      :consultation -> "Consulta"
      :vaccine -> "Vacina"
      :iatf -> "IATF"
    end
  end
end
