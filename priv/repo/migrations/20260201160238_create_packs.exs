defmodule Oddish.Repo.Migrations.CreatePacks do
  use Ecto.Migration

  def change do
    create table(:packs) do
      add :name, :string
      add :flock_type, :string
      add :animal_count, :integer
      add :status, :string
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:packs, [:org_id])
  end
end
