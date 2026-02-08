defmodule Oddish.Grazes.Graze do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grazes" do
    field :start_date, :date
    field :end_date, :date
    field :planned_period, :integer
    field :status, Ecto.Enum, values: [:planned, :ongoing, :finished, :canceled]
    field :org_id, :id

    belongs_to :pack, Oddish.Packs.Pack
    belongs_to :solta, Oddish.Soltas.Solta

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(graze, attrs, organization_scope) do
    graze
    |> cast(attrs, [
      :start_date,
      :end_date,
      :planned_period,
      :status,
      :pack_id,
      :solta_id
    ])
    |> validate_required([
      :start_date,
      :planned_period,
      :status,
      :pack_id,
      :solta_id
    ])
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def present_status(status) do
    case status do
      :planned -> "Planejado"
      :ongoing -> "Em andamento"
      :finished -> "Finalizado"
      :canceled -> "Cancelado"
    end
  end
end
