defmodule Oddish.SoltasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Soltas` context.
  """

  @doc """
  Generate a solta.
  """
  def solta_fixture(scope, attrs \\ %{}) do
    unique_name = "solta#{System.unique_integer()}"
    attrs =
      Enum.into(attrs, %{
        area: "120.5",
        grass_type: "some grass_type",
        name: unique_name
      })

    {:ok, solta} = Oddish.Soltas.create_solta(scope, attrs)
    solta
  end
end
