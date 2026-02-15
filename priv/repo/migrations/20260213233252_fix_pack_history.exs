defmodule Oddish.Repo.Migrations.FixPackHistory do
  use Ecto.Migration

  def change do
    rename table(:bovine_pack_history), to: table(:bovine_pack_histories)

    alter table(:bovine_pack_histories) do
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)
    end

    create unique_index(:soltas, [:org_id, :name], name: :soltas_unique_name_index)
  end
end
