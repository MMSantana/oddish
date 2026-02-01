defmodule Oddish.Repo.Migrations.CreateSoltas do
  use Ecto.Migration

  def change do
    create table(:soltas) do
      add :name, :string
      add :area, :decimal
      add :grass_type, :string
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:soltas, [:org_id])
  end
end
