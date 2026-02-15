defmodule Oddish.Repo.Migrations.FixPackHistory do
  use Ecto.Migration

  def up do
    execute "DROP TABLE IF EXISTS bovine_pack_history CASCADE"

    create table(:bovine_pack_histories) do
      add :bovine_id, references(:bovines, on_delete: :nilify_all)
      add :pack_id, references(:packs, on_delete: :nilify_all)
      add :start_date, :utc_datetime_usec
      add :end_date, :utc_datetime_usec
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:bovine_pack_histories, [:bovine_id])
    create index(:bovine_pack_histories, [:pack_id])

    create unique_index(:soltas, [:org_id, :name], name: :soltas_unique_name_index)
  end

  def down do

    create table(:bovine_pack_history) do
      add :bovine_id, references(:bovines, on_delete: :nilify_all)
      add :pack_id, references(:packs, on_delete: :nilify_all)
      add :start_date, :utc_datetime_usec
      add :end_date, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create index(:bovine_pack_history, [:bovine_id])
    create index(:bovine_pack_history, [:pack_id])
  end
end
