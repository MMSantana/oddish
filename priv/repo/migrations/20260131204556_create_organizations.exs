defmodule Oddish.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :slug, :string
      add :tier, :string

      timestamps(type: :utc_datetime)
    end

    create table(:user_organizations, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true

      add :organization_id, references(:organizations, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :role, :string, null: false, primary_key: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:slug])
    create index(:user_organizations, [:user_id])
    create index(:user_organizations, [:organization_id])
  end
end
