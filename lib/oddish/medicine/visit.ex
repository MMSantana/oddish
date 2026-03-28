defmodule Oddish.Medicine.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :date, :date
    field :paid?, :boolean
    field :notes, :string
    field :org_id, :id

    belongs_to :vet, Oddish.Medicine.Vet
    belongs_to :procedure, Oddish.Medicine.Procedure

    many_to_many :bovines, Oddish.Cattle.Bovine,
      join_through: "visits_bovines",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs, organization_scope) do
    visit
    |> cast(attrs, [:vet_id, :procedure_id, :paid?, :date, :notes])
    |> validate_required([:vet_id, :procedure_id, :date],
      message: "Não pode estar em branco"
    )
    |> put_change(:org_id, organization_scope.organization.id)
  end
end
