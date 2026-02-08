defmodule Oddish.Cattle.Bovine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bovines" do
    field :name, :string
    field :registration_number, :string
    field :gender, Ecto.Enum, values: [:male, :female]
    field :status, Ecto.Enum, values: [:active, :sold, :deceased, :lost]
    field :date_of_birth, :date
    field :description, :string
    field :observation, :string
    field :org_id, :id

    belongs_to :mother, __MODULE__
    has_many :offspring, __MODULE__, foreign_key: :mother_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bovine, attrs, organization_scope) do
    bovine
    |> cast(attrs, [
      :name,
      :registration_number,
      :gender,
      :mother_id,
      :date_of_birth,
      :description,
      :observation,
      :status
    ])
    |> validate_required([:name, :status, :gender])
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def present_gender(gender) do
    case gender do
      :male -> "Macho"
      :female -> "Fêmea"
    end
  end

  def present_status(status) do
    case status do
      :active -> "Ativo"
      :sold -> "Vendido"
      :deceased -> "Morto"
      :lost -> "Perdido"
    end
  end
end
