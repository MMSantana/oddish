defmodule Oddish.Repo.Migrations.AddAnimalDepartureTimes do
  use Ecto.Migration

  def change do
    alter table(:bovines) do
      add :departed_date, :date
    end
  end
end
