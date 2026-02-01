defmodule Oddish.SoltasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Soltas` context.
  """

  @doc """
  Generate a solta.
  """
  def solta_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        area: "120.5",
        grass_type: "some grass_type",
        name: "some name"
      })

    {:ok, solta} = Oddish.Soltas.create_solta(scope, attrs)
    solta
  end
end
