defmodule Oddish.Cattle.BovinePackHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bovine_pack_histories" do
    field :start_date, :utc_datetime_usec
    field :end_date, :utc_datetime_usec

    belongs_to :bovine, Oddish.Cattle.Bovine
    belongs_to :pack, Oddish.Packs.Pack

    timestamps()
  end

  def changeset(bovine_pack_history, attrs, organization_scope) do
    bovine_pack_history
    |> cast(attrs, [:bovine_id, :pack_id, :start_date, :end_date])
    |> validate_required([:bovine_id, :pack_id, :start_date])
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def create(current_scope, attrs) do
    %__MODULE__{}
    |> changeset(attrs, current_scope)
    |> Oddish.Repo.insert()
  end
end
