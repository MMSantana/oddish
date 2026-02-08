defmodule Oddish.Packs.Pack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packs" do
    field :name, :string
    field :flock_type, Ecto.Enum, values: [:bezerros, :bois, :novilhas, :vacas]
    field :animal_count, :integer
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :org_id, :id

    has_many :grazes, Oddish.Grazes.Graze

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pack, attrs, organization_scope) do
    pack
    |> cast(attrs, [:name, :flock_type, :animal_count, :status])
    |> validate_required([:name, :flock_type, :animal_count, :status])
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def present_status(status) do
    case status do
      :active -> "Ativo"
      :inactive -> "Inativo"
    end
  end

  def present_flock_type(flock_type) do
    case flock_type do
      :bezerros -> "Bezerros"
      :bois -> "Bois"
      :novilhas -> "Novilhas"
      :vacas -> "Vacas"
    end
  end
end
