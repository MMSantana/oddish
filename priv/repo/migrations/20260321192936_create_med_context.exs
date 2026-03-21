defmodule Oddish.Repo.Migrations.CreateVets do
  use Ecto.Migration

  def change do
    create table(:vets) do
      add :name, :string
      add :telephone, :string
      add :email, :string
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:vets, [:org_id])

    create table(:procedures) do
      add :name, :string
      add :type, :string
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:procedures, [:org_id])

    create table(:visits) do
      add :vet_id, references(:vets, type: :id, on_delete: :nothing)
      add :procedure_id, references(:procedures, type: :id, on_delete: :nothing)
      add :bovine_id, references(:bovines, type: :id, on_delete: :nothing)
      add :date, :date
      add :notes, :text
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:org_id])
  end
end
