defmodule Oddish.Repo.Migrations.AddNewbornField do
  use Ecto.Migration

  def change do
    alter table(:bovines) do
      add :newborn?, :boolean
    end
  end
end
