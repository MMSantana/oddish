defmodule Oddish.Cattle.BovinePackHistory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Oddish.Cattle.BovinePackHistory

  schema "bovine_pack_histories" do
    field :start_date, :utc_datetime_usec
    field :end_date, :utc_datetime_usec
    field :org_id, :id

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

  def create(%Oddish.Accounts.Scope{} = scope, attrs) do
    %__MODULE__{
      start_date: DateTime.now!("Etc/UTC")
    }
    |> changeset(attrs, scope)
    |> Oddish.Repo.insert()
  end

  def get!(scope, id) do
    Oddish.Repo.get_by!(BovinePackHistory, id: id, org_id: scope.organization.id)
  end

  def get_active(%Oddish.Accounts.Scope{} = scope, bovine) do
    true = scope.organization.id == bovine.org_id

    Oddish.Repo.one(
      from bph in BovinePackHistory,
        where: bph.bovine_id == ^bovine.id and is_nil(bph.end_date),
        select: bph
    )
  end

  def finish(%Oddish.Accounts.Scope{} = scope, bovine_pack_history) do
    bovine_pack_history
    |> changeset(
      %{
        end_date: DateTime.now!("Etc/UTC")
      },
      scope
    )
    |> Oddish.Repo.update()
  end
end
