defmodule Oddish.GrazesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Grazes` context.
  """

  @doc """
  Generate a graze.
  """
  def graze_fixture(scope, attrs \\ %{}) do
    solta = Oddish.SoltasFixtures.solta_fixture(scope)
    pack = Oddish.PacksFixtures.pack_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        end_date: ~D[2026-01-31],
        planned_period: 42,
        solta_id: solta.id,
        pack_id: pack.id,
        start_date: ~D[2026-01-31],
        status: :planned
      })

    {:ok, graze} = Oddish.Grazes.create_graze(scope, attrs)
    graze
  end
end
