defmodule Oddish.Repo.Migrations.LinkBovinesToPacks do
  use Ecto.Migration

  def change do
    alter table(:bovines) do
      add :pack_id, references(:packs, on_delete: :nilify_all)
    end

    alter table(:packs) do
      add :observation, :text
    end

    create table(:bovine_pack_history) do
      add :bovine_id, references(:bovines, on_delete: :nilify_all)
      add :pack_id, references(:packs, on_delete: :nilify_all)
      add :start_date, :utc_datetime_usec
      add :end_date, :utc_datetime_usec
    end

    create index(:bovines, [:pack_id])
    create index(:bovines, [:name])
    create index(:bovines, [:registration_number])
    create index(:bovine_pack_history, [:bovine_id])
    create index(:bovine_pack_history, [:pack_id])
  end
end
