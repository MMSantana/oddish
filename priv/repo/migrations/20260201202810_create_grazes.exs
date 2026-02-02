defmodule Oddish.Repo.Migrations.CreateGrazes do
  use Ecto.Migration

  def change do
    create table(:grazes) do
      add :flock_type, :string
      add :flock_quantity, :integer
      add :start_date, :date
      add :end_date, :date
      add :planned_period, :integer
      add :status, :string
      add :solta_id, references(:soltas, type: :id, on_delete: :nothing)
      add :org_id, references(:organizations, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:grazes, [:org_id, :solta_id])
  end
end
