defmodule Oddish.Repo.Migrations.CreateBovines do
  use Ecto.Migration

  def change do
    create table(:bovines) do
      add :name, :string
      add :registration_number, :string
      add :gender, :string
      add :status, :string
      add :mother_id, references(:bovines, type: :id, on_delete: :nilify_all)
      add :date_of_birth, :date
      add :description, :string
      add :observation, :text
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:bovines, [:org_id])
  end
end
