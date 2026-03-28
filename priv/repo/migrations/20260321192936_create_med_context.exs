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
      add :kind, :string
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:procedures, [:org_id])

    create table(:visits) do
      add :vet_id, references(:vets, type: :id, on_delete: :nothing)
      add :procedure_id, references(:procedures, type: :id, on_delete: :nothing)
      add :paid?, :boolean
      add :date, :date
      add :notes, :text
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:org_id])

    create table(:visits_bovines, primary_key: false) do
      add :visit_id, references(:visits, type: :id, on_delete: :delete_all), null: false
      add :bovine_id, references(:bovines, type: :id, on_delete: :delete_all), null: false
    end

    create index(:visits_bovines, [:visit_id])
    create index(:visits_bovines, [:bovine_id])
    create unique_index(:visits_bovines, [:visit_id, :bovine_id])
  end
end
