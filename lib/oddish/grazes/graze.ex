defmodule Oddish.Grazes.Graze do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grazes" do
    field :flock_type, Ecto.Enum, values: [:bezerros, :bois, :novilhas, :vacas]
    field :flock_quantity, :integer
    field :start_date, :date
    field :end_date, :date
    field :planned_period, :integer
    field :status, Ecto.Enum, values: [:planned, :ongoing, :finished, :canceled]
    field :org_id, :id

    belongs_to :solta, Oddish.Soltas.Solta

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(graze, attrs, organization_scope) do
    graze
    |> cast(attrs, [
      :flock_type,
      :flock_quantity,
      :start_date,
      :end_date,
      :planned_period,
      :status,
      :solta_id
    ])
    |> validate_required([
      :flock_type,
      :flock_quantity,
      :start_date,
      :planned_period,
      :status,
      :solta_id
    ])
    |> put_change(:org_id, organization_scope.organization.id)
  end
end
