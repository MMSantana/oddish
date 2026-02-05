defmodule Oddish.PacksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Packs` context.
  """

  @doc """
  Generate a pack.
  """
  def pack_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        animal_count: 42,
        flock_type: :bezerros,
        name: "some name",
        status: :active
      })

    {:ok, pack} = Oddish.Packs.create_pack(scope, attrs)
    pack
  end
end
