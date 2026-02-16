defmodule Oddish.Cattle.Bovine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bovines" do
    field :name, :string
    field :registration_number, :string
    field :gender, Ecto.Enum, values: [:male, :female]
    field :status, Ecto.Enum, values: [:active, :sold, :deceased, :lost]
    field :date_of_birth, :date
    field :departed_date, :date
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
      :departed_date,
      :description,
      :observation,
      :status,
      :pack_id
    ])
    |> validate_required([:status, :gender])
    |> validate_required_one_of([:name, :registration_number], ["Nome", "Número"])
    |> validate_status_departed_date_coupling()
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

  defp field_present?(nil), do: false
  defp field_present?(str) when is_binary(str), do: String.trim(str) != ""
  defp field_present?(_), do: true

  defp validate_required_one_of(changeset, fields, presentable_fields) when is_list(fields) do
    present? =
      Enum.any?(fields, fn field ->
        get_field(changeset, field) |> field_present?()
      end)

    if present? do
      changeset
    else
      add_error(
        changeset,
        hd(fields),
        "Um desses campos precisa estar presente: #{Enum.join(presentable_fields, ", ")}"
      )
    end
  end

  defp validate_status_departed_date_coupling(changeset) do
    status = get_field(changeset, :status)
    departed_date = get_field(changeset, :departed_date)

    cond do
      Enum.member?([:sold, :deceased, :lost], status) and is_nil(departed_date) ->
        add_error(changeset, :status, "Status final precisa de uma data de encerramento")

      status == :active and not is_nil(departed_date) ->
        add_error(changeset, :departed_date, "Data de encerramento precisa de um status final")

      true ->
        changeset
    end
  end
end
