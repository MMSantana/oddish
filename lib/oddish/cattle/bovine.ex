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

    belongs_to :pack, Oddish.Packs.Pack
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
      :status,
      :pack_id
    ])
    |> validate_required([:status, :gender])
    |> validate_required_one_of([:name, :registration_number])
    |> put_change(:org_id, organization_scope.organization.id)
  end

  def bovine_pack_history_changeset(bovine_pack_history, attrs) do
    bovine_pack_history
    |> cast(attrs, [:bovine_id, :pack_id, :start_date, :end_date])
    |> validate_required([:bovine_id, :pack_id, :start_date])
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

  defp validate_required_one_of(changeset, fields) when is_list(fields) do
    # Check if any of the fields have a value (either in changes or already in the data)
    present? =
      Enum.any?(fields, fn field ->
        get_field(changeset, field) |> field_present?()
      end)

    if present? do
      changeset
    else
      # If none are present, add an error to the first field (or both)
      add_error(
        changeset,
        hd(fields),
        "one of these fields must be present: #{Enum.join(fields, ", ")}"
      )
    end
  end

  defp field_present?(nil), do: false
  defp field_present?(str) when is_binary(str), do: String.trim(str) != ""
  defp field_present?(_), do: true
end
